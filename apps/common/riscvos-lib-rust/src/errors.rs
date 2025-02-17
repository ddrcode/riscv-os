#[derive(Debug)]
pub enum ConversionError {
    BufferTooSmall,
    InvalidUtf8,
    NoNullTerminator
}
