use core::num::traits::{Zero, One, BitSize};
use core::panic_with_felt252;
use core::starknet::secp256_trait::Secp256PointTrait;


pub trait Bitshift<T, U> {
    fn shl(self: T, shift: U) -> T;
    fn shr(self: T, shift: U) -> T;
}

pub impl BitshiftImpl<
    T,
    U,
    +Zero<T>,
    +Zero<U>,
    +One<T>,
    +One<U>,
    +Add<T>,
    +Add<U>,
    +Sub<T>,
    +Sub<U>,
    +Div<T>,
    +Mul<T>,
    +Rem<U>,
    +Div<U>,
    +Copy<T>,
    +Copy<U>,
    +Drop<T>,
    +Drop<U>,
    +PartialOrd<T>,
    +PartialOrd<U>,
    +PartialEq<U>,
    +BitSize<T>,
    +Into<usize, U>
> of Bitshift<T, U> {
    fn shl(self: T, shift: U) -> T {
        if shift > BitSize::<T>::bits().into() - One::one() {
            panic_with_felt252('mul Overflow');
        }
        let two = One::one() + One::one();
        self * fast_pow(two, shift)
    }

    fn shr(self: T, shift: U) -> T {
        if shift > BitSize::<T>::bits().try_into().unwrap() - One::one() {
            panic_with_felt252('mul Overflow');
        }
        let two = One::one() + One::one();
        self / fast_pow(two, shift)
    }
}

// Fast exponentiation using the square-and-multiply algorithm
// Reference:
// https://github.com/keep-starknet-strange/alexandria/blob/bcdca70afdf59c9976148e95cebad5cf63d75a7f/packages/math/src/fast_power.cairo#L12
pub fn fast_pow<
    T,
    U,
    +Copy<U>,
    +Copy<T>,
    +Drop<T>,
    +Drop<U>,
    +Zero<T>,
    +One<T>,
    +Zero<U>,
    +One<U>,
    +PartialEq<U>,
    +Add<U>,
    +Mul<T>,
    +Rem<U>,
    +Div<U>
>(
    base: T, exp: U
) -> T {
    if exp == Zero::zero() {
        return Zero::zero();
    }

    let mut res: T = One::one();
    let mut base: T = base;
    let mut exp: U = exp;

    let two: U = One::one() + One::one();

    loop {
        if exp % two == One::one() {
            res = res * base;
        }
        exp = exp / two;
        if exp == Zero::zero() {
            break res;
        }
        base = base * base;
    }
}
