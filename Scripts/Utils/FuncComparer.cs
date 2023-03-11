using System;
using System.Collections.Generic;

public partial class FuncComparer<T> : IComparer<T>
{
    private Func<T,T,int> _comp;
    public FuncComparer(Func<T,T,int> comp) {_comp = comp;}

    public int Compare(T f, T s) => _comp(f,s);
}
