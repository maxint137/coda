open Core_kernel
open Snark_params
open Snarky
open Tick
open Fold_lib
open Snark_bits

module type S = sig
  type t

  module Coinbase_data : sig
    type t

    type var
  end

  module Index : sig
    type t

    val gen : t Quickcheck.Generator.t

    module Vector : sig
      type t = int

      val length : t

      val empty : t

      val get : t -> t -> bool

      val set : t -> t -> bool -> t
    end

    val _to_bits : t -> bool list

    val fold_bits : t -> bool Fold.t

    val _fold : t -> (bool * bool * bool) Fold.t

    module Unpacked : sig
      type value = t

      type var

      include Snarkable.S with type value := value and type var := var
    end

    include Bits_intf.S with type t := t
  end

  module Stack : sig
    type t

    type var

    val push_exn : t -> Coinbase.t -> t

    val empty : t

    module Checked : sig
      type t = var

      val push : t -> Coinbase_data.var -> (t, 'a) Tick0.Checked.t

      val if_ :
        Tick0.Boolean.var -> then_:t -> else_:t -> (t, 'a) Tick0.Checked.t

      val empty : t
    end
  end

  module Hash : sig
    include Data_hash.Full_size

    type path = Pedersen.Digest.t list

    module Address : sig
      type var = Boolean.var list

      type value = int

      val typ : depth:int -> (var, value) Typ.t
    end

    type _ Request.t +=
      | Stack_path : Index.t -> path Request.t
      | Get_coinbase_stack : Index.t -> (Stack.t * path) Request.t
      | Set_coinbase_stack : Index.t * Stack.t -> unit Request.t
      | Find_index_of_newest_stack : Index.t Request.t
      | Find_index_of_oldest_stack : Index.t Request.t

    val get : var -> Index.Unpacked.var -> (Stack.var, _) Checked.t

    val merge : height:int -> t -> t -> t

    val empty_merkle_root : t

    val of_digest : Pedersen.Digest.t -> t

    (*val get : var -> Address.var -> Stack.var*)

    val update_stack :
         var
      -> is_new_stack:Boolean.var
      -> f:(Stack.var -> (Stack.var, 's) Checked.t)
      -> (var, 's) Checked.t

    val delete_stack : var -> (var, 's) Checked.t
  end

  val create : unit -> t

  val add_coinbase_exn : t -> coinbase:Coinbase.t -> is_new_stack:bool -> t

  val remove_coinbase_stack_exn : t -> t

  val merkle_root : t -> Hash.t

  val get_exn : t -> int -> Stack.t

  val path_exn : t -> int -> [`Left of Hash.t | `Right of Hash.t] sexp_list

  val set_exn : t -> int -> Stack.t -> t

  val find_index_exn : t -> int -> int
end