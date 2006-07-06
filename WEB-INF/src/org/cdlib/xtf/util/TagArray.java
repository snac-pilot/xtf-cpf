package org.cdlib.xtf.util;

/*
 * Copyright (c) 2006, Regents of the University of California
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *   this list of conditions and the following disclaimer in the documentation 
 *   and/or other materials provided with the distribution.
 * - Neither the name of the University of California nor the names of its
 *   contributors may be used to endorse or promote products derived from this 
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

import java.util.Hashtable;

/**
 * This class implements a resizable container for Tags, which are short
 * typed strings that are efficiently stored. The main goal for the class is 
 * to hold millions of small strings efficiently, without loading down the 
 * garbage collector with millions of objects. Strings are stored together 
 * in large buffers rather than individual objects.
 *
 * @author Martin Haye
 */
public class TagArray 
{
  private int      BLOCK_SIZE = 1024;
  
  private byte[][] blocks = { new byte[BLOCK_SIZE] };
  private short    nBlocks = 1;
  private byte[]   curBlock = blocks[0];
  private int      curBlockUsed = 0;
  
  private byte[]   tagType   = { 0 };
  private short[]  tagBlock  = { 0 };
  private int[]    tagOffset = { 0 };
  private short[]  tagLength = { 0 };
  private int      nTags = 1;
  
  private Hashtable typeTable = new Hashtable();
  private int       nTypes = 1; // type 0 means no type
  
  /**
   * Allocates a number for the given type string.
   * 
   * @param t   The type to find
   * @return    Its type ID
   */
  public int findType( String t )
  {
    Integer lookup = (Integer) typeTable.get( t );
    if( lookup == null ) {
        assert nTypes < 127 : "Too many types allocated - expand tagType to short";
        lookup = new Integer( nTypes );
        typeTable.put( t, lookup );
        nTypes++;
    }
    
    return lookup.intValue();
  } // findType()
  
  
  /**
   * Add a tag to the array
   * 
   * @param s   The string to add
   * @param t   The type ID of the new tag (from {@link #findType(String)})
   * @return    The new Tag's identifier
   */
  public int add( String s, int t )
  {
    // Do we have room in the current block? If not, make a new one.
    char[] srcChars = s.toCharArray();
    int length = srcChars.length;
    assert (length & 0x7fff) == length; // Make sure it fits in a short.
    ensureCapacity( length );
    
    // Allocate an identifier for the tag
    int tagId = allocateID();

    // Record the type, block, offset, and length of the tag.
    assert t >= 0 && t < nTypes : "Invalid tag type";
    tagType  [tagId] = (byte) t;
    tagBlock [tagId] = (short) (nBlocks - 1);
    tagLength[tagId] = (short) length;
    tagOffset[tagId] = curBlockUsed;
    
    // Convert the string to a byte array. For now, do it fast and dirty, e.g.
    // for chars > 127, retain the bottom 7 bits and set the 8th bit.
    //
    int destPos = curBlockUsed;
    for( int i = 0; i < length; i++ ) {
        char c = srcChars[i];
        if( c < 128 )
            curBlock[destPos++] = (byte) c;
        else
            curBlock[destPos++] = (byte) (c | 0x80);
    }
    
    // Advance the block top, and we're done.
    curBlockUsed += length;
    return tagId;
  } // add()
  
  /**
   * Allocate a new string identifier, expanding the arrays if necessary.
   * 
   * @return    The new identifier
   */
  private int allocateID()
  {
    // If the ID table doesn't have room, expand it.
    if( nTags == tagBlock.length ) {
        int newSize = nTags * 2;
        
        byte[] newTagType = new byte[newSize];
        System.arraycopy(tagType, 0, newTagType, 0, nTags);
        tagType = newTagType;
        
        short[] newTagBlock = new short[newSize];
        System.arraycopy(tagBlock, 0, newTagBlock, 0, nTags);
        tagBlock = newTagBlock;
        
        int[] newTagOffset = new int[newSize];
        System.arraycopy(tagOffset, 0, newTagOffset, 0, nTags);
        tagOffset = newTagOffset;
        
        short[] newTagLength = new short[newSize];
        System.arraycopy(tagLength, 0, newTagLength, 0, nTags);
        tagLength = newTagLength;
    }
    
    // Return the next ID.
    return nTags++;
  } // allocateID()
  
  /**
   * Checks if the current block has space for the given number of bytes. If not,
   * adds a new block.
   * 
   * @param nBytes    How many bytes to check for
   */
  private void ensureCapacity( int nBytes )
  {
    if( (curBlockUsed + nBytes) > BLOCK_SIZE )
        newBlock();
  } // ensureCapacity()
  
  /**
   * Allocates a new block, and sets {@link #curBlock} to point at it.
   */
  private void newBlock()
  {
    // If our array of blocks isn't big enough, double its size.
    if( nBlocks == blocks.length ) {
        byte[][] newBlocks = new byte[blocks.length * 2][];
        System.arraycopy( blocks, 0, newBlocks, 0, nBlocks );
        blocks = newBlocks;
    }
    
    // Now allocate the new block.
    assert nBlocks < 32767 : "Too many blocks - expand BLOCK_SIZE in code";
    curBlock = blocks[nBlocks] = new byte[BLOCK_SIZE];
    nBlocks++;
  } // newBlock()
  
}; // class BStringArray
