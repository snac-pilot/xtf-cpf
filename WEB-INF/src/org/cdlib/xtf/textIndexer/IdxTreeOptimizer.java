package org.cdlib.xtf.textIndexer;


/**
 * Copyright (c) 2004, Regents of the University of California
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
import java.io.File;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.Directory;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.cdlib.xtf.textEngine.NativeFSDirectory;
import org.cdlib.xtf.util.Path;
import org.cdlib.xtf.util.Trace;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/**
 * This class provides a simple mechanism for optimizing Lucene indices
 * after new documents have been added , updated, or removed. <br><br>
 *
 * When documents are added to a Lucene index, they form a "segment" that
 * contains information about the location and frequency for words appearing
 * in the document. Optimizing a Lucene index consists of merging multiple
 * segments into a single large segment. Doing so speeds searching by
 * eliminating the need to search multiple segments and combine the results.
 * <br><br>
 *
 * To use this class, simply instantiate a copy, and call the
 * {@link IdxTreeOptimizer#processDir(File) processDir()}
 * method on a directory containing an index. Note that the directory passed
 * may also be a root directory with many index sub-directories if desired.
 */
public class IdxTreeOptimizer 
{
  ////////////////////////////////////////////////////////////////////////////

  /**
   * Create an <code>IdxTreeOptimizer</code> instance and call this method to
   * optimize one or more Lucene indices. <br><br>
   *
   * @param  dir         The index database directory optimize. May be a
   *                     directory containing a single index, or the root
   *                     directory of a tree containing multiple indices.
   *                     <br><br>
   *
   * @throws Exception   Passes back any exceptions generated by the
   *                     {@link IdxTreeOptimizer#optimizeIndex(File) optimizeIndex()}
   *                     function, which is called for each index sub-directory
   *                     found. <br><br>
   *
   * @.notes             This method also calls itself recursively to process
   *                     potential index sub-directories below the passed
   *                     directory.
   */
  public void processDir(File dir)
    throws Exception 
  {
    // If the file we were passed was in fact a directory...
    if (dir.getAbsoluteFile().isDirectory()) 
    {
      // And it contains an index, optimize it.
      if (IndexReader.indexExists(dir.getAbsoluteFile()))
        optimizeIndex(dir);

      else 
      {
        // Get the list of files it contains.
        String[] files = dir.getAbsoluteFile().list();

        // And process each of them.
        for (int i = 0; i < files.length; i++)
          processDir(new File(dir, files[i]));
      }

      return;
    } // if( dir.isDirectory() )

    // The current file is not a directory, so skip it.
  } // processDir()

  ////////////////////////////////////////////////////////////////////////////

  /**
   * Performs the actual work of optimizing a Lucene index.
   * <br><br>
   *
   * @param  idxDirToOptimize   The index database directory clean. This
   *                            directory must contain a single Lucene index.
   *                            <br><br>
   *
   * @throws Exception          Passes back any exceptions generated by Lucene
   *                            during the opening or optimization of the
   *                            specified index.
   *                            <br><br>
   */
  public void optimizeIndex(File idxDirToOptimize)
    throws Exception 
  {
    // Tell what index we're working on...
    String path = Path.normalizePath(idxDirToOptimize.toString());
    Trace.info("Index: [" + path + "] ... ");
    Trace.tab();

    try 
    {
      // Try to open the index for writing. If we fail and 
      // throw, skip the index.
      //
      Directory dir = NativeFSDirectory.getDirectory(idxDirToOptimize);
      IndexWriter indexWriter = new IndexWriter(dir, new StandardAnalyzer(), false);

      // Previously we were paranoid about using compound files, on the
      // mistaken assumption that indexes could not be modified. This is
      // not true... the modifications simply take place at the next merge,
      // which is always the case in Lucene (compound or not.)
      //
      // Thus, do not do the following:
      // NO NO NO: indexWriter.setUseCompoundFile( false );

      // Optimize the index.
      indexWriter.optimize();

      // Close the index.
      indexWriter.close();

      // Indicate that we're done.
      Trace.more(Trace.info, "Done.");
    } //  try( to open the specified index )

    catch (Exception e) {
      Trace.error("*** Optimization Halted Due to Error:" + e);
      throw e;
    }

    Trace.untab();
  } // optimizeIndex()
}