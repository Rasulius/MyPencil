// Copyleft 2008 Chris Korda
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or any later version.
/*
        chris korda
 
		revision history:
		rev		date	comments
		00		17oct06	initial version
        01      28oct08	derive from array, add sorted insert
		
        template class to sort an array
 
*/

#ifndef CSORTARRAY_INCLUDED
#define CSORTARRAY_INCLUDED

#include "ArrayEx.h"

template<class TYPE, class ARG_TYPE>
class CSortArray : public CArrayEx<TYPE, ARG_TYPE> {
public:
// Operations
	void	Sort(bool Descending = FALSE);
	int		BinarySearch(ARG_TYPE newElement, bool ReturnInsertPos = FALSE);
	int		SortedInsert(ARG_TYPE newElement);

protected:
	static	int CmpAsc(const void *arg1, const void *arg2);
	static	int CmpDesc(const void *arg1, const void *arg2);
};

template<class TYPE, class ARG_TYPE>
AFX_INLINE int CSortArray<TYPE, ARG_TYPE>::CmpAsc(const void *arg1, const void *arg2)
{
	if (*(TYPE *)arg1 < *(TYPE *)arg2)
		return(-1);
	if (*(TYPE *)arg1 > *(TYPE *)arg2)
		return(1);
	return(0);
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE int CSortArray<TYPE, ARG_TYPE>::CmpDesc(const void *arg1, const void *arg2)
{
	if (*(TYPE *)arg1 > *(TYPE *)arg2)
		return(-1);
	if (*(TYPE *)arg1 < *(TYPE *)arg2)
		return(1);
	return(0);
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE void CSortArray<TYPE, ARG_TYPE>::Sort(bool Descending)
{
	qsort(m_pData, m_nSize, sizeof(TYPE), Descending ? CmpDesc : CmpAsc);
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE int CSortArray<TYPE, ARG_TYPE>::BinarySearch(ARG_TYPE key, bool ReturnInsertPos)
{
	int	first = 0;
	int	last = m_nSize - 1;
	while (first <= last) {
		int mid = (first + last) / 2;	// compute mid point
		if (key > m_pData[mid]) 
			first = mid + 1;	// repeat search in top half
		else if (key < m_pData[mid]) 
			 last = mid - 1;	// repeat search in bottom half
		else	// found it
			return(mid);	// return key position
	}
	if (ReturnInsertPos)
		return(first);	// return insert position
	return(-1);	// return failure
}

template<class TYPE, class ARG_TYPE>
AFX_INLINE int CSortArray<TYPE, ARG_TYPE>::SortedInsert(ARG_TYPE newElement)
{
	int	idx = BinarySearch(newElement, TRUE);	// if not found, return insert pos
	InsertAt(idx, newElement);
	return(idx);
}

#endif
