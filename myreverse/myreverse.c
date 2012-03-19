#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BUFSIZE 10

char buffer[BUFSIZE]; 
int read_ind = 0;
int processed_ind = 0;

void print(char *str, int sz) {
  int printed = 0; 
        
  while(sz > 0) {
    printed = write(1, str, sz);

    if (printed < 0) { 
      exit(1); 
    }      

    str = str + printed; 
    sz = sz - printed;     
  }
} 

void reverse(char *str, int sz) { 
  int i = 0;
  int temp = 0; 

  for (i = 0; i < sz / 2; i++) {
    temp = str[i]; 
    str[i] = str[sz - i - 1]; 
    str[sz - i - 1] = temp;   
  }   
} 

int end_of_str(char *str, int len) {
  int i = 0; 
  for (i = 0; str[i] != '\n' && i < len; i++);

  if (i == len) { 
    return -1; 
  } else {  
    return i;    
  } 
} 

char *get_from_buf(int *len) { 
  int end_ind = end_of_str(buffer + processed_ind, read_ind);
  char *res = NULL; 

  if (end_ind < 0) { 
    return NULL; 
  } else {  
    res = buffer + processed_ind; 
    *len = (end_ind + 1) - processed_ind;
        processed_ind = end_ind + 1;
    return res;    
  }
} 

int get_from_input(char **str) {
  int read_bytes = 0;
  int len = 0; 
  char *temp_str = *str; 

  while(1) {    
    if (processed_ind != 0) {
      read_ind -= processed_ind;
      memmove(buffer, buffer + processed_ind, read_ind);
      processed_ind = 0;
    } 

    temp_str = get_from_buf(&len); 
    
    if (temp_str != NULL) { 
      *str = temp_str; 
      return len;
    } else { 
      if (BUFSIZE == read_ind) { 
        while(temp_str == NULL) { 
          processed_ind = 0; 
          read_ind = 0;

          read_bytes = read(0, buffer, BUFSIZE);
          if (read_bytes == 0) { 
            *str = NULL;
            return 0; 
          } else if (read_bytes < 0){ 
            exit(1); 
          } else {
            read_ind += read_bytes;         
          } 
          temp_str = get_from_buf(&len);                    
        } 
      } else {
        read_bytes = read(0, buffer + read_ind, BUFSIZE - read_ind);
        if (read_bytes == 0) {   
          *str = NULL; 
          return 0; 
        } else if (read_bytes < 0) { 
          exit(1); 
        } else {
          read_ind += read_bytes;         
        }     
      } 
    } 
  } 
} 

int main() { 
  int bytes = 0; 
  char *str = NULL; 

  while(1) { 
    bytes = get_from_input(&str);
        
    if (str == NULL) { 
      return 1;
    } else if (bytes == 0) { 
      return 0;
    } else {  
      reverse(str, bytes - 1); 
      print(str, bytes);  
    } 
  }

  return 0;
}
