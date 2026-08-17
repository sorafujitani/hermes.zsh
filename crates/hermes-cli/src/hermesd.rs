#[tokio::main]
async fn main() {
    let result = match hermes_daemon::RuntimePaths::resolve() {
        Ok(paths) => hermes_daemon::run(paths).await,
        Err(error) => Err(error),
    };
    if let Err(error) = result {
        eprintln!("hermesd: {error}");
        std::process::exit(1);
    }
}
