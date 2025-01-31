use std::error::Error;

use fibonacci::*;

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = std::env::args().skip(1).collect();

    let runs: u32 = args.first().ok_or("missing number argument")?.parse()?;
    let sum: u32 = (0..runs).map(fibonacci).sum();

    println!("{}", sum);

    Ok(())
}
