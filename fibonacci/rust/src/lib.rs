use num::{Integer, NumCast, Unsigned};

pub fn fibonacci<T: Unsigned + Integer + NumCast + Copy>(number: T) -> T {
    let one = T::one();
    let two = T::from(2).expect("two");

    match number {
        o if o <= T::one() => o,
        _ => fibonacci(number - one) + fibonacci(number - two),
    }
}
