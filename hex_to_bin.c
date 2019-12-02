#include <stdio.h>
#include <string.h>
#define size_code 512
#define bits 32

unsigned int code[size_code];    
char bin[size_code][bits+1];

void get_code(char filename[]){
    
    FILE *fp;int i,j;    
    
    fp = fopen(filename, "r");
    if (fp == NULL){
        printf("Could not open file %s",filename);
        return;
    }

for(i=0;fscanf(fp,"%x", code+i)==1;i++);
fclose(fp);

for(;i<size_code;i++) code[i]=0;

}

void write_code(char filename[]){
    
    FILE *fp;int i;    
    
    fp = fopen(filename, "w");
    if (fp == NULL){
        printf("Could not open file %s",filename);
        return;
    }

for(i=0;i<size_code;i++) 
    fprintf(fp,"%s\n", bin[i]);

fclose(fp);
}

void num_to_bin(int num,char *str){

    for(int i=0;i<bits;i++)
        str[bits-1-i] = '0' + ((num >>i) & 1);       

    str[bits]=0;
}

int main(int argc,char *argv[]){
   
    int i;
    get_code(argv[1]);
    for(i=0;i<size_code;i++)
        num_to_bin(code[i],bin[i]);
    write_code(argv[2]);
}
