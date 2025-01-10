#include <iostream>
using namespace std;

int fibonacci(int n)
{
    if (n == 0)
        return 0;
    if (n == 1)
        return 1;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main(int argc, char *argv[])
{
    int u = stoi(argv[1]);
    int r = 0;
    for (int i = 1; i < u; i++)
    {
        r += fibonacci(i);
    }

    cout << r << endl;
    return 0;
}