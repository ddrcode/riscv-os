use crate::bindings;

impl From<bindings::I64> for i64 {
    fn from(val: bindings::I64) -> Self {
        let mut bytes = [0u8; 8];
        bytes[..4].copy_from_slice(&val.low.to_le_bytes());
        bytes[4..].copy_from_slice(&val.high.to_le_bytes());
        i64::from_le_bytes(bytes)
    }
}

impl From<bindings::U64> for u64 {
    fn from(val: bindings::U64) -> Self {
        let mut bytes = [0u8; 8];
        bytes[..4].copy_from_slice(&val.low.to_le_bytes());
        bytes[4..].copy_from_slice(&val.high.to_le_bytes());
        u64::from_le_bytes(bytes)
    }
}
