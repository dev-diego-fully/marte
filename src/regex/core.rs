use regex::bytes::Regex;

pub(crate) struct LuaRegex {
    regex: Regex,
}

impl LuaRegex {
    pub(in crate::regex) fn new(pattern: &str) -> Result<Self, ()> {
        match Regex::new(pattern) {
            Ok(rgx) => Ok(Self { regex: rgx }),
            Err(_) => Err(()),
        }
    }

    pub(in crate::regex) fn matches(&self, string: &[u8]) -> bool {
        self.regex.is_match(string)
    }

    pub(in crate::regex) fn replace(&self, string: &[u8], replacement: &[u8]) -> Vec<u8> {
        self.regex.replace(string, replacement).to_vec()
    }
}
