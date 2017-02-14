// Copyleft 2008 Chris Korda
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or any later version.
/*
        chris korda
 
		revision history:
		rev		date	comments
        00      14feb08	initial version
		
		enhanced array with copy ctor, assignment, and fast const access
 
*/

#ifndef CARRAYEX_INCLUDED
#define CARRAYEX_INCLUDED

#include <afxtempl.h>

template<class TYPE, class ARG_TYPE>
class CArrayEx : public CArray<TYPE, ARG_TYPE> {
public:
// Construction
	CArrayEx() {}	// inline body here to avoid internal compiler error
	CArrayEx(const CArrayEx& arr);
	CArrayEx& operator=(const CArrayEx& arr);

// Operations
	TYPE& ElementAt(int nIndex);
	const TYPE& ElementAt(int nIndex) const;
	TYPE& operator[](int nIndex);
	const TYPE& operator[](int nIndex) const;
};

template<class TYPE, class ARG_TYPE>
AFX_INLINE CArrayEx<TYPE, ARG_TYPE>::CArrayEx(const CArrayEx& arr)
{
	*this = arr;
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE CArrayEx<TYPE, ARG_TYPE>& 
CArrayEx<TYPE, ARG_TYPE>::operator=(const CArrayEx& arr)
{
	if (this != &arr)
		Copy(arr);
	return *this;
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE TYPE& CArrayEx<TYPE, ARG_TYPE>::ElementAt(int nIndex)
{
	ASSERT(nIndex >= 0 && nIndex < m_nSize);
	return m_pData[nIndex];
}

template<class TYPE, class ARG_TYPE>
const AFX_INLINE TYPE& CArrayEx<TYPE, ARG_TYPE>::ElementAt(int nIndex) const
{
	ASSERT(nIndex >= 0 && nIndex < m_nSize);
	return m_pData[nIndex];
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE TYPE& CArrayEx<TYPE, ARG_TYPE>::operator[](int nIndex)
{
	return ElementAt(nIndex);
}

template<class TYPE, class ARG_TYPE>
const AFX_INLINE TYPE& CArrayEx<TYPE, ARG_TYPE>::operator[](int nIndex) const
{
	return ElementAt(nIndex);	// base class uses GetAt which is too slow
}

#endif
