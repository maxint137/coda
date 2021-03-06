open Core
open Unsigned
module Balance = Currency.Balance

module Account = struct
  (* want bin_io, not available with Account.t *)
  type t = Coda_base.Account.Stable.V1.t
  [@@deriving bin_io, sexp, eq, compare, hash, yojson]

  type key = Coda_base.Account.Stable.V1.key
  [@@deriving bin_io, sexp, eq, compare, hash]

  (* use Account items needed *)
  let empty = Coda_base.Account.empty

  let public_key = Coda_base.Account.public_key

  let key_gen = Coda_base.Account.key_gen

  let gen = Coda_base.Account.gen

  let create = Coda_base.Account.create

  let balance = Coda_base.Account.balance

  let update_balance t bal = {t with Coda_base.Account.balance= bal}
end

(* below are alternative modules that use strings as public keys and UInt64 as balances for
   in accounts

   using these modules instead of Account and Balance above speeds up the
   ledger tests

   we don't use the alternatives for testing currently, because Account
   and Balance above are the modules used for actual ledgers
 *)

module Balance_not_used = struct
  include UInt64
  include Binable.Of_stringable (UInt64)

  let sexp_of_t t = [%sexp_of: string] (to_string t)

  let t_of_sexp sexp =
    let string_balance = [%of_sexp: string] sexp in
    of_string string_balance

  let equal x y = UInt64.compare x y = 0

  let gen = Quickcheck.Generator.map ~f:UInt64.of_int64 Int64.gen
end

module Account_not_used = struct
  type key = string [@@deriving sexp, show, bin_io, eq, compare, hash]

  type t =
    { public_key: key
    ; balance: Balance.Stable.V1.t
           [@printer
             fun fmt balance ->
               Format.pp_print_string fmt (Balance.to_string balance)] }
  [@@deriving bin_io, eq, show, fields]

  let sexp_of_t {public_key; balance} =
    [%sexp_of: string * string] (public_key, Balance.to_string balance)

  let t_of_sexp sexp =
    let public_key, string_balance = [%of_sexp: string * string] sexp in
    let balance = Balance.of_string string_balance in
    {public_key; balance}

  (* vanilla String.gen yields the empty string about half the time *)
  let key_gen = String.gen_with_length 10 Char.gen

  let set_balance {public_key; _} balance = {public_key; balance}

  let create public_key balance = {public_key; balance}

  let empty = {public_key= ""; balance= Balance.zero}

  let gen =
    let open Quickcheck.Let_syntax in
    let%bind public_key = String.gen in
    let%map int_balance = Int.gen in
    let nat_balance = abs int_balance in
    let balance = Balance.of_int nat_balance in
    {public_key; balance}
end

module Receipt = Coda_base.Receipt

module Hash = struct
  module T = struct
    type t = Md5.t [@@deriving sexp, hash, compare, bin_io, eq]

    let to_yojson t = `String (Md5.to_hex t)

    let of_yojson = function
      | `String s -> Ok (Md5.of_hex_exn s)
      | _ -> Error "expected string"
  end

  include T
  include Hashable.Make_binable (T)

  (* to prevent pre-image attack,
   * important impossible to create an account such that (merge a b = hash_account account) *)

  let hash_account account =
    Md5.digest_string ("0" ^ Format.sprintf !"%{sexp: Account.t}" account)

  let merge ~height a b =
    let res =
      Md5.digest_string
        (sprintf "test_ledger_%d:" height ^ Md5.to_hex a ^ Md5.to_hex b)
    in
    res

  let empty_account = hash_account Account.empty
end

module Intf = Merkle_ledger.Intf

module In_memory_kvdb : Intf.Key_value_database = struct
  module Bigstring_frozen = struct
    module T = struct
      include Bigstring

      (* we're not mutating Bigstrings, which would invalidate hashes
       OK to use these hash functions
       *)
      let hash = hash_t_frozen

      let hash_fold_t = hash_fold_t_frozen
    end

    include T
    include Hashable.Make_binable (T)
  end

  type t =
    {uuid: Uuid.Stable.V1.t; table: Bigstring_frozen.t Bigstring_frozen.Table.t}
  [@@deriving sexp]

  let to_alist t =
    let unsorted = Bigstring_frozen.Table.to_alist t.table in
    (* sort by key *)
    List.sort
      ~compare:(fun (k1, _) (k2, _) -> Bigstring_frozen.compare k1 k2)
      unsorted

  let get_uuid t = t.uuid

  let create ~directory:_ =
    {uuid= Uuid.create (); table= Bigstring_frozen.Table.create ()}

  let close _ = ()

  let get t ~key = Bigstring_frozen.Table.find t.table key

  let set t ~key ~data = Bigstring_frozen.Table.set t.table ~key ~data

  let set_batch tbl ~key_data_pairs =
    List.iter key_data_pairs ~f:(fun (key, data) -> set tbl ~key ~data)

  let remove t ~key = Bigstring_frozen.Table.remove t.table key
end

module Storage_locations : Intf.Storage_locations = struct
  (* TODO: The name of this value should be dynamically generated per test run*)
  let key_value_db_dir = ""
end

module Key = struct
  module Stable = struct
    module V1 = struct
      type t = Account.key [@@deriving sexp, bin_io, eq, compare, hash]
    end

    module Latest = V1
  end

  type t = Stable.Latest.t [@@deriving sexp, compare, hash]

  let to_string = Signature_lib.Public_key.Compressed.to_base64

  let gen = Account.key_gen

  let empty = Account.empty.public_key

  let gen_keys num_keys =
    (* TODO : the Quickcheck generator for Public_key.Compressed produces duplicates
       as a workaround, we generate extra keys, remove duplicates, and take as many as needed
       Issue #1078 notes the problem with the generators
     *)
    let num_to_gen = num_keys + (num_keys / 5) in
    let more_than_enough_keys =
      Quickcheck.random_value
        (Quickcheck.Generator.list_with_length num_to_gen gen)
    in
    let unique_keys =
      List.dedup_and_sort ~compare:Stable.Latest.compare more_than_enough_keys
    in
    assert (List.length unique_keys >= num_keys) ;
    List.take unique_keys num_keys

  include Hashable.Make_binable (Stable.Latest)
  include Comparable.Make (Stable.Latest)
end

module Base_inputs = struct
  module Key = Key
  module Balance = Balance
  module Account = Account
  module Hash = Hash
end
