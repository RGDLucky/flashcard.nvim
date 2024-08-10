use std::ffi::{CString, CStr};
use std::os::raw::c_char;
use std::fs::File;
use std::path::PathBuf;
use std::io::{self, BufReader, Result};
use dirs;
use serde_json;
use serde::{Serialize, Deserialize};

// TODO: delete
pub fn add(left: usize, right: usize) -> usize {
    left + right
}

// TODO: delete
#[no_mangle]
pub extern "C" fn greeting() -> *const c_char {
    CString::new("Hello").unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s); 
        }
    }
}

#[no_mangle]
pub fn add_card(title: *const c_char, description: *const c_char, file_name: *const c_char) -> bool {
    let rust_title = c_str_to_string(title);
    let rust_description = c_str_to_string(description);
    let rust_file_name = c_str_to_string(file_name);
    let result = write_json(rust_title, rust_description, rust_file_name);
    match result {
        Ok(()) => true,
        Err(_) => false,
    }
}

// Function to convert a C string to a Rust String
fn c_str_to_string(c_str: *const c_char) -> String {
    unsafe {
        CStr::from_ptr(c_str).to_string_lossy().into_owned()
    }
}

fn write_json(title: String, description: String, file_name: String) -> Result<()> {
    let path = expand_tilde(&file_name);

     let entry = Entry {
        title: title.to_string(),
        description: description.to_string(),
    };

    let mut content = FileContent { entries: Vec::new() };

    if path.exists() {
        let file = File::open(&path)?;
        let reader = io::BufReader::new(file);
        content = serde_json::from_reader(reader)?;
    }

    content.entries.push(entry);

    let file = File::create(&path)?;
    serde_json::to_writer(file, &content)?;

    Ok(())
}

#[no_mangle]
pub extern "C" fn get_cards(file_name: *const c_char) -> *const c_char {
    let path = expand_tilde(&c_str_to_string(file_name)).to_string_lossy().to_string();
    let result = read_json(path);
    let arr: Vec<Entry> = match result {
        Ok(entries) => entries,
        Err(_) => Vec::new(),
    };
    let json_string = serialize_entries_to_lua_string(arr);
    CString::new(json_string).unwrap().into_raw()
}

fn read_json(path: String) -> Result<Vec<Entry>> {
    let file = File::open(&path)?;
    let reader = BufReader::new(file);
    let content: FileContent = serde_json::from_reader(reader)?;
    Ok(content.entries)
}

fn expand_tilde(path: &str) -> PathBuf {
    if path.starts_with("~/") {
        if let Some(home_dir) = dirs::home_dir() {
            let stripped_path = &path[2..]; // Remove the ~/
            return home_dir.join(stripped_path);
        }
    }
    PathBuf::from(path)
}

fn serialize_entries_to_lua_string(entries: Vec<Entry>) -> String {
    let json_string = serde_json::to_string(&entries).unwrap();
    json_string
}

#[derive(Serialize, Deserialize, Debug)]
struct Entry {
    title: String,
    description: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct FileContent {
    entries: Vec<Entry>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
