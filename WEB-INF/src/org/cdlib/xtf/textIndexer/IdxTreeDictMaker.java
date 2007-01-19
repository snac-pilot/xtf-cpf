package org.cdlib.xtf.textIndexer;

/**
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
 * 
 * Acknowledgements:
 * 
 * A significant amount of new and/or modified code in this module
 * was made possible by a grant from the Andrew W. Mellon Foundation,
 * as part of the Melvyl Recommender Project.
 */

import java.io.File;

import org.apache.lucene.index.IndexReader;
import org.apache.lucene.search.spell.SpellWriter;

import org.cdlib.xtf.util.Path;
import org.cdlib.xtf.util.ProgressTracker;
import org.cdlib.xtf.util.Trace;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/**
 * This class provides a simple mechanism for generating a spelling correction
 * dictionary after new documents have been added or updated. <br><br>
 * 
 * To use this class, simply instantiate a copy, and call the 
 * {@link IdxTreeDictMaker#processDir(File) processDir()}
 * method on a directory containing an index. Note that the directory passed
 * may also be a root directory with many index sub-directories if desired.
 */

public class IdxTreeDictMaker

{
  
  ////////////////////////////////////////////////////////////////////////////

  /**
   * Create an <code>IdxTreeDictMaker</code> instance and call this method to 
   * create spelling dictionaries for one or more Lucene indices. <br><br>
   *                     
   * @param  dir         The index database directory to scan. May be a 
   *                     directory containing a single index, or the root 
   *                     directory of a tree containing multiple indices. 
   *                     <br><br>
   * 
   * @.notes             This method also calls itself recursively to process
   *                     potential index sub-directories below the passed
   *                     directory. 
   */

  public void processDir( File dir ) throws Exception
  
  {
    
    // If the file we were passed was in fact a directory...
    if( dir.getAbsoluteFile().isDirectory() ) {
      
      // And it contains an index, optimize it.
      if( IndexReader.indexExists( dir.getAbsoluteFile() ) )
        makeDict( dir );
      
      else {
        
        // Get the list of files it contains.
        String[] files = dir.getAbsoluteFile().list();
        
        // And process each of them.
        for( int i = 0; i < files.length; i++ )
          processDir( new File(dir, files[i]) );
      }
      
      return;
      
    } // if( dir.isDirectory() )
    
    // The current file is not a directory, so skip it.
    
  } // processDir()
  
  
  ////////////////////////////////////////////////////////////////////////////

  /**
   * Performs the actual work of creating a spelling dictionary.   
   * <br><br>
   *                     
   * @param  mainIdxDir         The index database directory to scan. This 
   *                            directory must contain a single Lucene index.
   *                            <br><br>
   * 
   * @throws Exception          Passes back any exceptions generated by Lucene 
   *                            during the dictionary generation process.
   *                            <br><br> 
   */

  public void makeDict( File mainIdxDir ) throws Exception 
  
  {
    // Detect if spelling data is present.
    String indexPath    = Path.normalizePath(mainIdxDir.toString());
    String spellIdxPath = indexPath + "spellDict/";
    String wordQueuePath    = spellIdxPath + "newWords.txt";
    String pairQueuePath    = spellIdxPath + "newPairs.txt";
    if( new File(wordQueuePath).length() < 1 &&
        new File(pairQueuePath).length() < 1 )
    {
        return;
    }
  
    // Tell what index we're working on...
    String mainIdxPath = Path.normalizePath( mainIdxDir.toString() );
    Trace.info( "Index: [" + mainIdxPath + "] ... " );
    Trace.tab();
    Trace.tab(); // for phase
    
    SpellWriter spellWriter = null;
    
    try {

        // Open the SpellWriter. We don't have to specify a stopword set for
        // this phase (it's only used during queuing.)
        //
        spellWriter = SpellWriter.open( spellIdxPath, null, 3 );
        
        // Perform the update.
        spellWriter.flushQueuedWords(new ProgressTracker() {
          public void report(int pctDone, String descrip) {
              String pctTxt = Integer.toString(pctDone);
              while( pctTxt.length() < 3 ) 
                  pctTxt = " " + pctTxt;
              Trace.info( "[" + pctTxt + "%] " + descrip );
          }
        });
    } //  try( to open the specified index )
    
    catch ( Exception e ) {      
        Trace.error( "*** Dictionary Creation Halted Due to Error:" + e );
        throw e;
    }
    finally {
        spellWriter.close();
    }
  
    Trace.untab(); // for phase
    Trace.untab();
    Trace.info( "Done." );
    
  } // makeDict()

} // class IdxTreeDictMaker