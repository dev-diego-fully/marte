use regex::bytes::{Captures, Regex};

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

    pub(in crate::regex) fn test(&self, string: &[u8]) -> bool {
        self.regex.is_match(string)
    }

    pub(in crate::regex) fn find_first<'a>(&'a self, string: &'a [u8]) -> Option<Captures<'a>> {
        self.regex.captures(string)
    }

    pub(in crate::regex) fn process_all(
        &self,
        string: &[u8],
        operation: impl Fn(&Captures, usize) -> Result<bool, &'static str>,
        limit: Option<u64>,
    ) -> Result<(), &str> {
        let limit = limit.map(|u| u as usize).unwrap_or(usize::MAX);

        for (i, cap) in self.regex.captures_iter(string).enumerate().take(limit) {
            match operation(&cap, i) {
                Ok(true) => continue,
                Ok(false) => break,
                Err(msg) => return Err(msg),
            };
        }
        Ok(())
    }

    pub(in crate::regex) fn collect_all<'a>(
        &'a self,
        string: &'a [u8],
        limit: Option<u64>,
    ) -> std::iter::Take<regex::bytes::CaptureMatches<'a, 'a>> {
        let lim = match limit {
            Some(l) => l as usize,
            None => usize::MAX,
        };
        self.regex.captures_iter(string).take(lim)
    }

    pub(in crate::regex) fn replace_all(
        &self,
        string: &[u8],
        replacement: &[u8],
        limit: Option<u64>,
    ) -> Vec<u8> {
        (match limit {
            Some(1) => self.regex.replace(string, replacement),
            Some(n) => self.regex.replacen(string, n as usize, replacement),
            None => self.regex.replace_all(string, replacement),
        })
        .to_vec()
    }

    pub(in crate::regex) fn split_all<'a>(
        &self,
        string: &'a [u8],
        limit: Option<u64>,
    ) -> Vec<&'a [u8]> {
        match limit {
            Some(n) => self.regex.splitn(string, n as usize).collect(),
            None => self.regex.split(string).collect(),
        }
    }

    pub(in crate::regex) fn capture_names(&self) -> regex::bytes::CaptureNames<'_> {
        self.regex.capture_names()
    }
}
