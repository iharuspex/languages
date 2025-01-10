#include <cstdlib>
#include <cstdio>

int fibonnaci(int n){
    if (n==0){
        return 0;
    }else if(n==1){
        return 1;
    }

    return fibonnaci(n-1) + fibonnaci(n-2);
        
}

int main(int argc, char* argv[]){
    int u = std::atoi(argv[1]);
    int sum=0;
    for(int i=1;i<u;i++){
        sum+=fibonnaci(i);
    }
    printf("%d\n",sum);
    return 0;
}