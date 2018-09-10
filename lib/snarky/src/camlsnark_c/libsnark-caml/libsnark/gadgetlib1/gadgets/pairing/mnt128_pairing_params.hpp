/** @file
 *****************************************************************************

 Declaration of specializations of pairing_selector<ppT> to
 - pairing_selector<libff::mnt4_pp>, and
 - pairing_selector<libff::mnt6_pp>.

 See pairing_params.hpp .

 *****************************************************************************
 * @author     This file is part of libsnark, developed by SCIPR Lab
 *             and contributors (see AUTHORS).
 * @copyright  MIT license (see LICENSE file)
 *****************************************************************************/

#ifndef MNT128_PAIRING_PARAMS_HPP_
#define MNT128_PAIRING_PARAMS_HPP_

#include <libff/algebra/curves/mnt_128/mnt4128/mnt4128_pp.hpp>
#include <libff/algebra/curves/mnt_128/mnt6128/mnt6128_pp.hpp>

#include <libsnark/gadgetlib1/gadgets/fields/fp2_gadgets.hpp>
#include <libsnark/gadgetlib1/gadgets/fields/fp3_gadgets.hpp>
#include <libsnark/gadgetlib1/gadgets/fields/fp4_gadgets.hpp>
#include <libsnark/gadgetlib1/gadgets/fields/fp6_gadgets.hpp>
#include <libsnark/gadgetlib1/gadgets/pairing/pairing_params.hpp>

namespace libsnark {

template<typename ppT>
class mnt_e_over_e_miller_loop_gadget;

template<typename ppT>
class mnt_e_times_e_over_e_miller_loop_gadget;

template<typename ppT>
class mnt4_final_exp_gadget;

template<typename ppT>
class mnt6_final_exp_gadget;

template<typename ppT>
class mnt4_final_exp_value_gadget;

template<typename ppT>
class mnt6_final_exp_value_gadget;

/**
 * Specialization for MNT4.
 */
template<>
class pairing_selector<libff::mnt4128_pp> {
public:
    typedef libff::Fr<libff::mnt4128_pp> FieldT;
    typedef libff::Fqe<libff::mnt6128_pp> FqeT;
    typedef libff::Fqk<libff::mnt6128_pp> FqkT;

    typedef Fp3_variable<FqeT> Fqe_variable_type;
    typedef Fp3_mul_gadget<FqeT> Fqe_mul_gadget_type;
    typedef Fp3_mul_by_lc_gadget<FqeT> Fqe_mul_by_lc_gadget_type;
    typedef Fp3_sqr_gadget<FqeT> Fqe_sqr_gadget_type;

    typedef Fp6_variable<FqkT> Fqk_variable_type;
    typedef Fp6_mul_gadget<FqkT> Fqk_mul_gadget_type;
    typedef Fp6_mul_by_2345_gadget<FqkT> Fqk_special_mul_gadget_type;
    typedef Fp6_sqr_gadget<FqkT> Fqk_sqr_gadget_type;

    typedef libff::mnt6128_pp other_curve_type;

    typedef mnt_e_over_e_miller_loop_gadget<libff::mnt4128_pp> e_over_e_miller_loop_gadget_type;
    typedef mnt_e_times_e_over_e_miller_loop_gadget<libff::mnt4128_pp> e_times_e_over_e_miller_loop_gadget_type;
    typedef mnt4_final_exp_gadget<libff::mnt4128_pp> final_exp_gadget_type;
    typedef mnt4_final_exp_value_gadget<libff::mnt4128_pp> final_exp_value_gadget_type;

    static const constexpr mp_size_t q_limbs = libff::mnt6128_q_limbs;

    static const constexpr libff::bigint<libff::mnt6128_Fr::num_limbs> &pairing_loop_count = libff::mnt6128_ate_loop_count;
    static const constexpr bool &is_loop_count_neg = libff::mnt6128_ate_is_loop_count_neg;
    static const constexpr FqeT &twist = libff::mnt6128_twist;

    static const constexpr libff::bigint<libff::mnt6128_Fr::num_limbs> &final_exponent_last_chunk_abs_of_w0 = libff::mnt6128_final_exponent_last_chunk_abs_of_w0;
    static const constexpr bool &final_exponent_last_chunk_is_w0_neg = libff::mnt6128_final_exponent_last_chunk_is_w0_neg;
    static const constexpr libff::bigint<libff::mnt6128_Fr::num_limbs> &final_exponent_last_chunk_w1 = libff::mnt6128_final_exponent_last_chunk_w1;
};

/**
 * Specialization for MNT6.
 */
template<>
class pairing_selector<libff::mnt6128_pp> {
public:
    typedef libff::Fr<libff::mnt6128_pp> FieldT;

    typedef libff::Fqe<libff::mnt4128_pp> FqeT;
    typedef libff::Fqk<libff::mnt4128_pp> FqkT;

    typedef Fp2_variable<FqeT> Fqe_variable_type;
    typedef Fp2_mul_gadget<FqeT> Fqe_mul_gadget_type;
    typedef Fp2_mul_by_lc_gadget<FqeT> Fqe_mul_by_lc_gadget_type;
    typedef Fp2_sqr_gadget<FqeT> Fqe_sqr_gadget_type;

    typedef Fp4_variable<FqkT> Fqk_variable_type;
    typedef Fp4_mul_gadget<FqkT> Fqk_mul_gadget_type;
    typedef Fp4_mul_gadget<FqkT> Fqk_special_mul_gadget_type;
    typedef Fp4_sqr_gadget<FqkT> Fqk_sqr_gadget_type;

    typedef libff::mnt4128_pp other_curve_type;

    typedef mnt_e_over_e_miller_loop_gadget<libff::mnt6128_pp> e_over_e_miller_loop_gadget_type;
    typedef mnt_e_times_e_over_e_miller_loop_gadget<libff::mnt6128_pp> e_times_e_over_e_miller_loop_gadget_type;
    typedef mnt6_final_exp_gadget<libff::mnt6128_pp> final_exp_gadget_type;
    typedef mnt6_final_exp_value_gadget<libff::mnt6128_pp> final_exp_value_gadget_type;

    static const constexpr libff::bigint<libff::mnt4128_Fr::num_limbs> &pairing_loop_count = libff::mnt4128_ate_loop_count;
    static const constexpr bool &is_loop_count_neg = libff::mnt4128_ate_is_loop_count_neg;
    static const constexpr FqeT &twist = libff::mnt4128_twist;

    static const constexpr mp_size_t q_limbs = libff::mnt4128_q_limbs;

    static const constexpr libff::bigint<libff::mnt4128_Fr::num_limbs> &final_exponent_last_chunk_abs_of_w0 =
      libff::mnt4128_final_exponent_last_chunk_abs_of_w0;
    static const constexpr bool &final_exponent_last_chunk_is_w0_neg =
      libff::mnt4128_final_exponent_last_chunk_is_w0_neg;
    static const constexpr libff::bigint<libff::mnt4128_Fr::num_limbs> &final_exponent_last_chunk_w1 =
      libff::mnt4128_final_exponent_last_chunk_w1;
};

} // libsnark

#endif // MNT_PAIRING_PARAMS_HPP_