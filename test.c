#include <stdio.h>
#include <string.h>

int main() {
    char buf[] = "Hello";
    char buf2[] = "Hello2";

    printf("%d", strcmp(buf, buf2));
    return 0;
}