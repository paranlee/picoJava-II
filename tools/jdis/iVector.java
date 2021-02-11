//****************************************************************
//***
//***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
//***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
//***    The contents of this file are subject to the current
//***    version of the Sun Community Source License, picoJava-II
//***    Core ("the License").  You may not use this file except
//***    in compliance with the License.  You may obtain a copy
//***    of the License by searching for "Sun Community Source
//***    License" on the World Wide Web at http://www.sun.com.
//***    See the License for the rights, obligations, and
//***    limitations governing use of the contents of this file.
//***
//***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
//***    trademarks and logos, Java, picoJava, and all Java-based
//***    trademarks and logos are trademarks or registered trademarks
//***    of Sun Microsystems, Inc. in the United States and other
//***    countries.
//***
//*****************************************************************




package com.sun.picojava.jdis; 

import java.io.*;
import java.util.NoSuchElementException;

/**
 * iVector class (a growable array of int integers).<p>
 * 
 * Each vector tries to optimize storage management by maintaining
 * a capacity and a capacityIncrement. The capacity is always at
 * least as large as the vector size; it is usually larger because
 * as elements are added to the vector, the vector's
 * storage increases in chunks the size of capacityIncrement. Setting
 * the capacity to what you want before inserting a large number of
 * objects will reduce the amount of incremental reallocation.
 * You can safely ignore the capacity and the vector will still work
 * correctly.
 *
 * @version 	1.29, 12/01/95
 * @author	Jonathan Payne (Vector)
 * @author	Lee Boynton (Vector)
 * @author	Alexei Kaigorodov (iVector)
 */

public
class iVector {
  /**
   * The buffer where elements are stored.
   */
  int data[];

  /**
   * The number of elements in the buffer.
   */
  int length;

  /**
   * The size of the increment. If it is 0 the size of the
   * the buffer is doubled everytime it needs to grow.
   */
  protected int capacityIncrement;

  /**
   * Constructs an empty vector with the specified storage
   * capacity and the specified capacityIncrement.
   * @param initialCapacity the initial storage capacity of the vector
   * @param capacityIncrement how much to increase the element's 
   * size by.
   */
  public iVector(int initialCapacity, int capacityIncrement) {
	this.data = new int[initialCapacity];
	this.capacityIncrement = capacityIncrement;
  }

  /**
   * Constructs an empty vector with the specified storage capacity.
   * @param initialCapacity the initial storage capacity of the vector
   */
  public iVector(int initialCapacity) {
	this(initialCapacity, 0);
  }

  /**
   * Constructs an empty vector.
   */
  public iVector() {
	this(20);
  }

  /**
   * Constructs a full vector.
   */
  public iVector(int data[], int capacityIncrement) {
	this.length=data.length;
	this.data = data;
	this.capacityIncrement = capacityIncrement;
  }

  /**
   * Constructs a full vector.
   */
  public iVector(int data[]) {
	this(data,0);
  }

  /**
   * Copies the elements of this vector into the specified array.
   * @param anArray the array where elements get copied into
   */
  public final synchronized void copyInto(int anArray[]) {
	int i = length;
	while (i-- > 0) {
	    anArray[i] = data[i];
	}
  }

  /**
   * Trims the vector's capacity down to size. Use this operation to
   * minimize the storage of a vector. Subsequent insertions will
   * cause reallocation.
   */
  public final synchronized void trimToSize() {
	int oldCapacity = data.length;
	if (length < oldCapacity) {
	    int oldData[] = data;
	    data = new int[length];
	    System.arraycopy(oldData, 0, data, 0, length);
	}
  }

  /**
   * Ensures that the vector has at least the specified capacity.
   * @param minCapacity the desired minimum capacity
   */
  public final synchronized void ensureCapacity(int minCapacity) {
	int oldCapacity = data.length;
	if (minCapacity <= oldCapacity) return;
	int oldData[] = data;
	int newCapacity = (capacityIncrement > 0) ?
		(oldCapacity + capacityIncrement) : (oldCapacity * 2);
	if (newCapacity < minCapacity) {
		newCapacity = minCapacity;
	}
	data = new int[newCapacity];
	System.arraycopy(oldData, 0, data, 0, length);
  }

  /**
   * Sets the size of the vector. If the size shrinks, the extra elements
   * (at the end of the vector) are lost; if the size increases, the
   * new elements are set to 0.
   * @param newSize the new size of the vector
   */
  public final synchronized void setSize(int newSize) {
	if (newSize > length) {
	    ensureCapacity(newSize);
	    for (int i=length; i<newSize ; i++) {
			data[i] = 0;
	    }
	}
	length = newSize;
  }

  /**
   * Returns the current capacity of the vector.
   */
  public final int capacity() {
	return data.length;
  }

  /**
   * Returns the number of elements in the vector.
   * Note that this is not the same as the vector's capacity.
   */
  public final int size() {
	return length;
  }

  /**
   * Returns true if the collection contains no values.
   */
  public final boolean isEmpty() {
	return length == 0;
  }

  /**
   * Returns true if the specified object is a value of the 
   * collection.
   * @param elem the desired element
   */
  public final boolean contains(int elem) {
	return indexOf(elem, 0) >= 0;
  }

  /**
   * Searches for the specified object, starting from the first position
   * and returns an index to it.
   * @param elem the desired element
   * @return the index of the element, or -1 if it was not found.
   */
  public final int indexOf(int elem) {
	return indexOf(elem, 0);
  }

  /**
   * Searches for the specified object, starting at the specified 
   * position and returns an index to it.
   * @param elem the desired element
   * @param index the index where to start searching
   * @return the index of the element, or -1 if it was not found.
   */
  public final synchronized int indexOf(int elem, int index) {
	for (int i = index ; i < length ; i++) {
	    if (elem==data[i]) {
		return i;
	    }
	}
	return -1;
  }

  /**
   * Searches backwards for the specified object, starting from the last
   * position and returns an index to it. 
   * @param elem the desired element
   * @return the index of the element, or -1 if it was not found.
   */
  public final int lastIndexOf(int elem) {
	return lastIndexOf(elem, length);
  }

  /**
   * Searches backwards for the specified object, starting from the specified
   * position and returns an index to it. 
   * @param elem the desired element
   * @param index the index where to start searching
   * @return the index of the element, or -1 if it was not found.
   */
  public final synchronized int lastIndexOf(int elem, int index) {
	for (int i = index ; --i >= 0 ; ) {
	    if (elem==data[i]) {
		return i;
	    }
	}
	return -1;
  }

  /**
   * Returns the element at the specified index.
   * @param index the index of the desired element
   * @exception ArrayIndexOutOfBoundsException If an invalid 
   * index was given.
   */
  public final synchronized int elementAt(int index) {
	if (index >= length) {
	    throw new ArrayIndexOutOfBoundsException(index + " >= " + length);
	}
	try {
	    return data[index];
	} catch (ArrayIndexOutOfBoundsException e) {
	    throw new ArrayIndexOutOfBoundsException(index + " < 0");
	}
  }

  /**
   * Returns the first element of the sequence.
   * @exception NoSuchElementException If the sequence is empty.
   */
  public final synchronized int firstElement() {
	if (length == 0) {
	    throw new NoSuchElementException();
	}
	return data[0];
  }

  /**
   * Returns the last element of the sequence.
   * @exception NoSuchElementException If the sequence is empty.
   */
  public final synchronized int lastElement() {
	if (length == 0) {
	    throw new NoSuchElementException();
	}
	return data[length - 1];
  }

  /**
   * Sets the element at the specified index to be the specified object.
   * The previous element at that position is discarded.
   * @param obj what the element is to be set to
   * @param index the specified index
   * @exception ArrayIndexOutOfBoundsException If the index was 
   * invalid.
   */
  public final synchronized void setElementAt(int obj, int index) {
	if (index >= length) {
	    throw new ArrayIndexOutOfBoundsException(index + " >= " + 
						     length);
	}
	data[index] = obj;
  }

  /**
   * Adds the specified object as the last element of the vector.
   * @param obj the element to be added
   */
  public final synchronized int addElement(int obj) {
	ensureCapacity(length + 1);
	data[length] = obj;
	return length++;
  }

  /**
   * Sets the element at the specified index to be the specified object.
   * if size is unsufficient, vector is enlarged.
   * The previous element at that position, if any, is discarded.
   * @param obj what the element is to be set to
   * @param index the specified index
   */
  public final synchronized void addElement(int obj, int index) {
	if (index >= length) ensureCapacity(length=index+1);
	data[index] = obj;
  }

  /**
   * Removes all elements of the vector. The vector becomes empty.
   */
  public final synchronized void removeAllElements() {
	length = 0;
  }

}





