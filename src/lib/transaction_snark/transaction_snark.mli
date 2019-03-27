open Core
open Coda_base
open Snark_params

module Proof_type : sig
  module Stable : sig
    module V1 : sig
      type t = [`Base | `Merge] [@@deriving bin_io, sexp, yojson]
    end

    module Latest = V1
  end

  type t = Stable.Latest.t [@@deriving sexp, yojson]
end

module Statement : sig
  type t =
    { source: Coda_base.Frozen_ledger_hash.Stable.V1.t
    ; target: Coda_base.Frozen_ledger_hash.Stable.V1.t
    ; supply_increase: Currency.Amount.Stable.V1.t
    ; fee_excess: Currency.Fee.Signed.Stable.V1.t
    ; proof_type: Proof_type.Stable.V1.t }
  [@@deriving sexp, hash, compare, yojson]

  module Stable :
    sig
      module V1 : sig
        type t =
          { source: Coda_base.Frozen_ledger_hash.Stable.V1.t
          ; target: Coda_base.Frozen_ledger_hash.Stable.V1.t
          ; supply_increase: Currency.Amount.Stable.V1.t
          ; fee_excess: Currency.Fee.Signed.Stable.V1.t
          ; proof_type: Proof_type.Stable.V1.t }
        [@@deriving sexp, bin_io, hash, compare, yojson]
      end

      module Latest = V1
    end
    with type V1.t = t

  val gen : t Quickcheck.Generator.t

  val merge : t -> t -> t Or_error.t

  include Hashable.S_binable with type t := t

  include Comparable.S with type t := t
end

type t [@@deriving sexp, yojson]

module Stable :
  sig
    module V1 : sig
      type t [@@deriving bin_io, sexp, yojson]
    end

    module Latest = V1
  end
  with type V1.t = t

val create :
     source:Frozen_ledger_hash.t
  -> target:Frozen_ledger_hash.t
  -> proof_type:Proof_type.t
  -> supply_increase:Currency.Amount.t
  -> fee_excess:Currency.Amount.Signed.t
  -> sok_digest:Sok_message.Digest.t
  -> proof:Tock.Proof.t
  -> t

val proof : t -> Tock.Proof.t

val statement : t -> Statement.t

val sok_digest : t -> Sok_message.Digest.t

module Keys : sig
  module Proving : sig
    type t =
      { base: Tick.Groth16.Proving_key.t
      ; wrap: Tock.Proving_key.t
      ; merge: Tick.Groth16.Proving_key.t }
    [@@deriving bin_io]

    val dummy : t

    module Location : Stringable.S

    val load : Location.t -> (t * Md5.t) Async.Deferred.t
  end

  module Verification : sig
    type t =
      { base: Tick.Groth16.Verification_key.t
      ; wrap: Tock.Verification_key.t
      ; merge: Tick.Groth16.Verification_key.t }
    [@@deriving bin_io]

    val dummy : t

    module Location : Stringable.S

    val load : Location.t -> (t * Md5.t) Async.Deferred.t
  end

  module Location : sig
    type t =
      {proving: Proving.Location.t; verification: Verification.Location.t}

    include Stringable.S with type t := t
  end

  module Checksum : sig
    type t = {proving: Md5.t; verification: Md5.t}
  end

  type t = {proving: Proving.t; verification: Verification.t}

  val create : unit -> t

  val cached :
    unit -> (Location.t * Verification.t * Checksum.t) Async.Deferred.t
end

module Verification : sig
  module type S = sig
    val verify : t -> message:Sok_message.t -> bool

    val verify_against_digest : t -> bool

    val verify_complete_merge :
         Sok_message.Digest.Checked.t
      -> Frozen_ledger_hash.var
      -> Frozen_ledger_hash.var
      -> Currency.Amount.var
      -> (Tock.Proof.t, 's) Tick.As_prover.t
      -> (Tick.Boolean.var, 's) Tick.Checked.t
  end

  module Make (K : sig
    val keys : Keys.Verification.t
  end) : S
end

val check_transaction :
     sok_message:Sok_message.t
  -> source:Frozen_ledger_hash.t
  -> target:Frozen_ledger_hash.t
  -> Transaction.t
  -> Tick.Handler.t
  -> unit

val check_user_command :
     sok_message:Sok_message.t
  -> source:Frozen_ledger_hash.t
  -> target:Frozen_ledger_hash.t
  -> User_command.With_valid_signature.t
  -> Tick.Handler.t
  -> unit

val generate_transaction_witness :
     ?preeval:bool
  -> sok_message:Sok_message.t
  -> source:Frozen_ledger_hash.t
  -> target:Frozen_ledger_hash.t
  -> Transaction.t
  -> Tick.Handler.t
  -> unit

module type S = sig
  include Verification.S

  val of_transaction :
       ?preeval:bool
    -> sok_digest:Sok_message.Digest.t
    -> source:Frozen_ledger_hash.t
    -> target:Frozen_ledger_hash.t
    -> Transaction.t
    -> Tick.Handler.t
    -> t

  val of_user_command :
       sok_digest:Sok_message.Digest.t
    -> source:Frozen_ledger_hash.t
    -> target:Frozen_ledger_hash.t
    -> User_command.With_valid_signature.t
    -> Tick.Handler.t
    -> t

  val of_fee_transfer :
       sok_digest:Sok_message.Digest.t
    -> source:Frozen_ledger_hash.t
    -> target:Frozen_ledger_hash.t
    -> Fee_transfer.t
    -> Tick.Handler.t
    -> t

  val merge : t -> t -> sok_digest:Sok_message.Digest.t -> t Or_error.t
end

module Make (K : sig
  val keys : Keys.t
end) : S

val constraint_system_digests : unit -> (string * Md5.t) list
