#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define ROPE_SIZE 10
#define BUFSIZE 3

typedef struct List List; 

struct List {
	int str_size;
	char *str; 
	int size; 
	List *prev;
};

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

int end_of_str(char *str, int start, int len) {
  int i = 0; 

  for (i = start; str[i] != '\n' && i < len; i++)
	;

  if (i == len) { 
    return -1; 
  } else {  
    return i;    
  } 
} 

/*rope*/
List* new_list(int size, int str_size, char *str, List *prev) { 
	List *res = (List*) malloc(sizeof(List));
	res->str_size = str_size;
	res->str = str; 
	res->size = size;
	res->prev = prev; 
	return res;
} 

void delete(List *current) {
	if (current->str != NULL) { 
		free(current->str); 
	}
 
	if (current->prev != NULL) { 
		delete(current->prev);
	} 

	free(current);
} 

void reverse_print(List* current) { 
	if (current->str_size > 0) { 
		reverse(current->str, current->str_size);
		print(current->str, current->str_size);
	}  

	if (current->prev != NULL) 
		reverse_print(current->prev);

} 

List* new_string(List *parent, char *str, int start, int len) { 
	char *buf = (char *) malloc((len - start) * sizeof(char));
	memcpy(buf, str + (start) * sizeof(char), (len - start) * sizeof(char));
	return new_list((len - start) + parent->size, (len - start), buf, parent);
}

int main() { 
	List *rope = new_list(0, 0, NULL, NULL);
	char buffer[BUFSIZE]; 
	int excess = 0;
	int n_read = 0;
	int index_ = -1; 
	int old_index = 0; 

	while(1) {
		n_read = read(0, buffer, BUFSIZE);
		if (n_read == 0) { 
			delete(rope); 
			return 0;
		} else if (n_read < 0) { 
			delete(rope); 
			return 1;
		} else { 
			do { 
				old_index = index_ + 1;
				index_ = end_of_str(buffer, old_index, n_read);
				if (index_ == -1) { 
					if (excess != 1) {
						if ((rope->size + n_read) > ROPE_SIZE) 
							excess = 1; 
						else  
							rope = new_string(rope, buffer, old_index, n_read);	
					} 
				} else { 
					if ((excess != 1) && ((rope->size + index_) <= ROPE_SIZE)) { 
						rope = new_string(rope, buffer, old_index, index_);
						reverse_print(rope);
						print("\n", 1); 
					}
					delete(rope);
					excess = 0; 
					rope = new_list(0, 0, NULL, NULL); 
				} 						
			} while(index_ != -1); 
		} 	
	} 

	return 0;
} 
