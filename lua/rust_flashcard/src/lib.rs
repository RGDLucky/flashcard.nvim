use std::ffi::{CString, CStr};
use std::os::raw::c_char;
use std::fs;
use std::io::Result;

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
pub fn add_card(title: *const c_char, description: *const c_char, file_name: *const c_char) -> bool {
    let rust_title = c_str_to_string(title);
    let rust_description = c_str_to_string(description);
    let rust_file_name = c_str_to_string(file_name);
    println!("{}", rust_title);
    println!("{}", rust_description);
    println!("{}", rust_file_name);
    let _ = write_test(rust_title, rust_description, rust_file_name);
    true
}

// Function to convert a C string to a Rust String
fn c_str_to_string(c_str: *const c_char) -> String {
    unsafe {
        CStr::from_ptr(c_str).to_string_lossy().into_owned()
    }
}

fn write_test(title: String, description: String, file_name: String) -> Result<()> {
    let path = "rust_flash_example.txt";
    let content = title + &description + &file_name;

    fs::write(path, content)?;

    println!("Successfully wrote to {}", path);
    Ok(())
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
