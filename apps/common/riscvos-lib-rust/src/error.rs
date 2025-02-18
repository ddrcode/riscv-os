#[derive(Debug)]
pub enum ConversionError {
    BufferTooSmall,
    InvalidUtf8,
    NoNullTerminator
}

#[repr(i32)]
pub enum OSError {
    Unknown = 0,
    CommandNotFound = 1,
    MissingArgument = 2,
    NotSupported = 3,
    InvalidArgument = 4,
    StackOverflow = 5
}

