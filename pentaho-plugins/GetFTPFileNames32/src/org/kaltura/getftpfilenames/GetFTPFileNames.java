/* Copyright (c) 2007 Pentaho Corporation.  All rights reserved. 
 * This software was developed by Pentaho Corporation and is provided under the terms 
 * of the GNU Lesser General Public License, Version 2.1. You may not use 
 * this file except in compliance with the license. If you need a copy of the license, 
 * please go to http://www.gnu.org/licenses/lgpl-2.1.txt. The Original Code is Pentaho 
 * Data Integration.  The Initial Developer is Pentaho Corporation.
 *
 * Software distributed under the GNU Lesser Public License is distributed on an "AS IS" 
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or  implied. Please refer to 
 * the license for the specific language governing your rights and limitations.*/

package org.kaltura.getftpfilenames;

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPConnectMode;
//import com.enterprisedt.net.ftp.FTPException;
//import com.enterprisedt.net.ftp.FTPTransferType;
//import com.enterprisedt.net.ftp.FTPFile;

import java.io.IOException;
import java.net.InetAddress;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileType;
import org.pentaho.di.core.Const;
import org.pentaho.di.core.Result;
import org.pentaho.di.core.ResultFile;
import org.pentaho.di.core.exception.KettleException;
import org.pentaho.di.core.exception.KettleStepException;
import org.pentaho.di.core.fileinput.FileInputList;
import org.pentaho.di.core.logging.LogWriter;
import org.pentaho.di.core.row.RowDataUtil;
import org.pentaho.di.core.row.RowMeta;
import org.pentaho.di.core.vfs.KettleVFS;
import org.pentaho.di.job.Job;
import org.pentaho.di.job.entries.ftp.Messages;
import org.pentaho.di.repository.Repository;
import org.pentaho.di.trans.Trans;
import org.pentaho.di.trans.TransMeta;
import org.pentaho.di.trans.step.BaseStep;
import org.pentaho.di.trans.step.StepDataInterface;
import org.pentaho.di.trans.step.StepInterface;
import org.pentaho.di.trans.step.StepMeta;
import org.pentaho.di.trans.step.StepMetaInterface;

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPConnectMode;
import com.enterprisedt.net.ftp.FTPException;
import com.enterprisedt.net.ftp.FTPFile;
import com.enterprisedt.net.ftp.FTPTransferType;

/**
 * Read all sorts of text files, convert them to rows and writes these to one or more output streams.
 * 
 * @author Matt
 * @since 4-apr-2003
 */
public class GetFTPFileNames extends BaseStep implements StepInterface
{
    private GetFTPFileNamesMeta meta;
    private GetFTPFileNamesData data;
    
    private FTPClient ftpClient;

    public GetFTPFileNames(StepMeta stepMeta, StepDataInterface stepDataInterface, int copyNr, TransMeta transMeta, Trans trans)
    {
        super(stepMeta, stepDataInterface, copyNr, transMeta, trans);
    }
	
	/**
	 * Build an empty row based on the meta-data...
	 * 
	 * @return
	 */

	private Object[] buildEmptyRow()
	{
        Object[] rowData = RowDataUtil.allocateRowData(data.outputRowMeta.size());
 
		 return rowData;
	}
	
    public boolean processRow(StepMetaInterface smi, StepDataInterface sdi) throws KettleException
    {
    	if(!meta.isFileField())
		{
    		if (data.filenr >= data.filessize)
  	        {
  	            setOutputDone();
  	            return false;
  	        }
		}else
		{
			if (data.filenr >= data.filessize)
  	        {
				// Grab one row from previous step ...
				data.readrow=getRow();
  	        }

			if (data.readrow==null)
  	        {
  	            setOutputDone();
  	            return false;
  	        }
			
	        if (first)
	        {	        	
	            first = false;

				data.inputRowMeta = getInputRowMeta();
				data.outputRowMeta = data.inputRowMeta.clone();
		        meta.getFields(data.outputRowMeta, getStepname(), null, null, this);

	            // Get total previous fields
	            data.totalpreviousfields=data.inputRowMeta.size();
	            
	        	// Check is filename field is provided
				if (Const.isEmpty(meta.getDynamicFilenameField()))
				{
					logError(Messages.getString("GetFTPFileNames.Log.NoField"));
					throw new KettleException(Messages.getString("GetFTPFileNames.Log.NoField"));
				}
				
	            
				// cache the position of the field			
				if (data.indexOfFilenameField<0)
				{	
					data.indexOfFilenameField =data.inputRowMeta.indexOfValue(meta.getDynamicFilenameField());
					if (data.indexOfFilenameField<0)
					{
						// The field is unreachable !
						logError(Messages.getString("GetFTPFileNames.Log.ErrorFindingField",meta.getDynamicFilenameField())); //$NON-NLS-1$ //$NON-NLS-2$
						throw new KettleException(Messages.getString("GetFTPFileNames.Exception.CouldnotFindField",meta.getDynamicFilenameField())); //$NON-NLS-1$ //$NON-NLS-2$
					}
				}  
				
	        	// If wildcard field is specified, Check if field exists
				if (!Const.isEmpty(meta.getDynamicWildcardField()))
				{
					if (data.indexOfWildcardField<0)
					{
						data.indexOfWildcardField =data.inputRowMeta.indexOfValue(meta.getDynamicWildcardField());
						if (data.indexOfWildcardField<0)
						{
							// The field is unreachable !
							logError(Messages.getString("GetFTPFileNames.Log.ErrorFindingField")+ "[" + meta.getDynamicWildcardField()+"]"); //$NON-NLS-1$ //$NON-NLS-2$
							throw new KettleException(Messages.getString("GetFTPFileNames.Exception.CouldnotFindField",meta.getDynamicWildcardField())); //$NON-NLS-1$ //$NON-NLS-2$
						}
					}
				}
	        }
		}// end if first
    	
        try
        {
        	Object[] outputRow = buildEmptyRow();
        	int outputIndex = 0;
			Object extraData[] = new Object[data.nrStepFields];
        	if(meta.isFileField())
        	{
    			if (data.filenr >= data.filessize)
    		    {
    				// Get value of dynamic filename field ...
    	    		String filename=getInputRowMeta().getString(data.readrow,data.indexOfFilenameField);
    	    		String wildcard="";
    	    		if(data.indexOfWildcardField>=0)
    	    			wildcard=getInputRowMeta().getString(data.readrow,data.indexOfWildcardField);
    	    		
    	    		String[] filesname={filename};
    		      	String[] filesmask={wildcard};
    		      	String[] filesrequired={"N"};
    		      	// Get files list
    		      	data.files = meta.getDynamicFileList(ftpClient, getTransMeta(), filesname, filesmask, filesrequired);
    		      	data.filessize=data.files.nrOfFiles();
    		      	data.filenr=0;
    		     }
        		
        		// Clone current input row
    			outputRow = data.readrow.clone();
        	}
        	if(data.filessize>0)
        	{
	        	data.file = data.files.getFile(data.filenr);
	
         	
                //// filename
        		//extraData[outputIndex++]=KettleVFS.getFilename(data.file);

                //// short_filename
        		//extraData[outputIndex++]=data.file.getName().getBaseName();

//                try
//                {
//    				 // Path
//                	 extraData[outputIndex++]=KettleVFS.getFilename(data.file.getParent());
//
//                	 // type
//    				 extraData[outputIndex++]=data.file.getType().toString();
//    				 
//                     // exists
//    				 extraData[outputIndex++]=Boolean.valueOf(data.file.exists());
//                    
//                     // ishidden
//    				 extraData[outputIndex++]=Boolean.valueOf(data.file.isHidden());
//
//                     // isreadable
//    				 extraData[outputIndex++]=Boolean.valueOf(data.file.isReadable());
//    				
//                     // iswriteable
//    				 extraData[outputIndex++]=Boolean.valueOf(data.file.isWriteable());
//
//                     // lastmodifiedtime
//    				 extraData[outputIndex++]=new Date( data.file.getContent().getLastModifiedTime() );
//
//                     // size
//                     Long size = null;
//                     if (data.file.getType().equals(FileType.FILE))
//                     {
//                         size = new Long( data.file.getContent().getSize() );
//                     }
//   
//   				 	 extraData[outputIndex++]=size;
//   				 	
//                }
//                catch (IOException e)
//                {
//                    throw new KettleException(e);
//                }

//                 // extension
//	 		  	 extraData[outputIndex++]=data.file.getName().getExtension();
//   	
//                 // uri	
//				 extraData[outputIndex++]= data.file.getName().getURI();
//   	
//                 // rooturi	
//				 extraData[outputIndex++]= data.file.getName().getRootURI();
//  
//		         // See if we need to add the row number to the row...  
//		         if (meta.includeRowNumber() && !Const.isEmpty(meta.getRowNumberField()))
//		         {
//					  extraData[outputIndex++]= new Long(data.rownr);
//		         }
		
		         data.rownr++;
		        // Add row data
		        outputRow = RowDataUtil.addRowData(outputRow,data.totalpreviousfields, extraData);
                // Send row
		        putRow(data.outputRowMeta, outputRow);
		        
	      		if (meta.getRowLimit()>0 && data.rownr>=meta.getRowLimit())  // limit has been reached: stop now.
	      		{
	   	           setOutputDone();
	   	           return false;
	      		}
	      		
            }
        }
        catch (Exception e)
        {
            throw new KettleStepException(e);
        }

        data.filenr++;

        if (checkFeedback(getLinesInput())) 	
        {
        	if(log.isBasic()) logBasic(Messages.getString("GetFTPFileNames.Log.NrLine",""+getLinesInput()));
        }

        return true;
    }

    private void handleMissingFiles() throws KettleException
    {
        List<FTPFileObject> nonExistantFiles = data.files.getNonExistantFiles();

        if (nonExistantFiles.size() != 0)
        {
            String message = FTPFileInputList.getRequiredFilesDescription(nonExistantFiles);
            logBasic("ERROR: Missing " + message);
            throw new KettleException("Following required files are missing: " + message);
        }

        List<FTPFileObject> nonAccessibleFiles = data.files.getNonAccessibleFiles();
        if (nonAccessibleFiles.size() != 0)
        {
            String message = FTPFileInputList.getRequiredFilesDescription(nonAccessibleFiles);
            logBasic("WARNING: Not accessible " + message);
            throw new KettleException("Following required files are not accessible: " + message);
        }
    }

    public boolean init(StepMetaInterface smi, StepDataInterface sdi)
    {
        meta = (GetFTPFileNamesMeta) smi;
        data = (GetFTPFileNamesData) sdi;

        if (super.init(smi, sdi))
        {
        	
			try
			{
				// TODO: Validate FTP input
				
				OpenFTPConnection();
				
				 // Create the output row meta-data
	            data.outputRowMeta = new RowMeta();
	            meta.getFields(data.outputRowMeta, getStepname(), null, null, this); // get the metadata populated
	            data.nrStepFields=  data.outputRowMeta.size();
	            
				if(!meta.isFileField())
				{
	                data.files = meta.getFileList(ftpClient, getTransMeta());
	                data.filessize=data.files.nrOfFiles();
					handleMissingFiles();
				}else
					data.filessize=0;
		            
			}
			catch(Exception e)
			{
				logError("Error initializing step: "+e.toString());
				logError(Const.getStackTracker(e));
				return false;
			}
		
            data.rownr = 1L;
			data.filenr = 0;
			data.totalpreviousfields=0;
            
            return true;
          
        }
        return false;
    }

    public void dispose(StepMetaInterface smi, StepDataInterface sdi)
    {
        meta = (GetFTPFileNamesMeta) smi;
        data = (GetFTPFileNamesData) sdi;
        if(data.file!=null)
        {
        	try{
        	    	data.file.close();
        	    	data.file=null;
        	}catch(Exception e){}
        	
        }
        super.dispose(smi, sdi);
    }

    @Override
    public void setOutputDone() {
       	super.setOutputDone();
       	CloseFTPConnection(); 
    }
    
    //
    // Run is were the action happens!
    public void run()
    {
    	BaseStep.runStepThread(this, meta, data);
    }
    
    
	private boolean OpenFTPConnection(/*Result previousResult, int nr, Repository rep, Job parentJob*/)
	{
		//LogWriter log = LogWriter.getInstance();
		//log4j.info(Messages.getString("JobEntryFTP.Started", serverName)); //$NON-NLS-1$
		
		//Result result = previousResult;
		//result.setNrErrors(1);
		//result.setResult( false );
		//NrErrors = 0;
		//NrfilesRetrieved=0;
		//successConditionBroken=false;
		//boolean exitjobentry=false;
		//limitFiles=Const.toInt(environmentSubstitute(getLimit()),10);

		
		// Here let's put some controls before stating the job
//		if(movefiles)
//		{
//			if(Const.isEmpty(movetodirectory))
//			{
//				log.logError(toString(), Messages.getString("JobEntryFTP.MoveToFolderEmpty"));
//				return result;
//			}
//				
//		}
//		
//		if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.Start")); //$NON-NLS-1$

        //String realMoveToFolder=null;
		if (ftpClient.connected())
		{
			CloseFTPConnection();
			OpenFTPConnection();
		}
		try
		{
			// Create ftp client to host:port ...
			ftpClient = new FTPClient();
            String realServername = environmentSubstitute(meta.getHost());
            //String realServerPort = environmentSubstitute(port);
            //ftpclient.setRemoteAddr(InetAddress.getByName(realServername));
            //if(!Const.isEmpty(realServerPort))
            //{
            //	 ftpclient.setRemotePort(Const.toInt(realServerPort, 21));
            //}

            if (!Const.isEmpty(meta.getProxyHost())) 
            {
          	  String realProxy_host = environmentSubstitute(meta.getProxyHost());
          	  ftpClient.setRemoteAddr(InetAddress.getByName(realProxy_host));
          	  //if ( log.isDetailed() )
          	  //    log.logDetailed(toString(), Messages.getString("JobEntryFTP.OpenedProxyConnectionOn",realProxy_host));

          	  // FIXME: Proper default port for proxy    	  
          	  //int port = Const.toInt(environmentSubstitute(proxyPort), 21);
          	  //if (port != 0) 
          	  //{
          	     ftpClient.setRemotePort(meta.getProxyPort());
          	  //}
            } 
            else 
            {
                ftpClient.setRemoteAddr(InetAddress.getByName(realServername));
                
                //if ( log.isDetailed() )
          	    //  log.logDetailed(toString(), Messages.getString("JobEntryFTP.OpenedConnectionTo",realServername));
                ftpClient.setRemotePort(meta.getPort());
            }
            
            
			// set activeConnection connectmode ...
            if (meta.isActiveFtpConnectionMode()){
                ftpClient.setConnectMode(FTPConnectMode.ACTIVE);
                if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.SetActive")); //$NON-NLS-1$
            }
            else{
                ftpClient.setConnectMode(FTPConnectMode.PASV);
                if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.SetPassive")); //$NON-NLS-1$
            }
			
			// Set the timeout
			ftpClient.setTimeout(meta.getTimeout());
		      //if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.SetTimeout", String.valueOf(timeout))); //$NON-NLS-1$
			
			ftpClient.setControlEncoding(meta.getEncoding());
		    //  if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.SetEncoding", controlEncoding)); //$NON-NLS-1$

			// login to ftp host ...
            ftpClient.connect();
			
            String realUsername = environmentSubstitute(meta.getUsername()) +
            (!Const.isEmpty(meta.getProxyHost()) ? "@" + realServername : "") + 
            (!Const.isEmpty(meta.getProxyUsername()) ? " " + environmentSubstitute(meta.getProxyUsername()) 
        		                           : ""); 
	            
            String realPassword = environmentSubstitute(meta.getPassword()) + 
            (!Const.isEmpty(meta.getProxyPassword()) ? " " + environmentSubstitute(meta.getProxyPassword()) : "" );
            
            
            ftpClient.login(realUsername, realPassword);
			//  Remove password from logging, you don't know where it ends up.
			//if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.LoggedIn", realUsername)); //$NON-NLS-1$

			// move to spool dir ...
			//if (!Const.isEmpty(ftpDirectory)) {
            //    String realFtpDirectory = environmentSubstitute(ftpDirectory);
            //    realFtpDirectory=normalizePath(realFtpDirectory);
            //    ftpclient.chdir(realFtpDirectory);
            //    if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.ChangedDir", realFtpDirectory)); //$NON-NLS-1$
			//}	

			//Create move to folder if necessary
			//if(movefiles && !Const.isEmpty(movetodirectory)) {
			//	realMoveToFolder=environmentSubstitute(movetodirectory);
			//	realMoveToFolder=normalizePath(realMoveToFolder);
			//	// Folder exists?
//				boolean folderExist=true;
//				try{
//					folderExist=ftpclient.exists(realMoveToFolder);
//				}
//				catch (Exception e){
//					// Assume file does not exist !!
//				}
//				
//				if(!folderExist){
//					if(createmovefolder){
//						ftpclient.mkdir(realMoveToFolder);
//						if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.MoveToFolderCreated",realMoveToFolder));
//					}else{
//						log.logError(toString(),Messages.getString("JobEntryFTP.MoveToFolderNotExist"));
//						exitjobentry=true;
//						NrErrors++;
//					}
//				}
//			}
			
//			if(!exitjobentry)
//			{
//				// Get all the files in the current directory...
//				FTPFile[] ftpFiles = ftpclient.dirDetails(".");
//				
//			    //if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.FoundNFiles", String.valueOf(filelist.length))); //$NON-NLS-1$
//				if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.FoundNFiles", String.valueOf(ftpFiles.length))); //$NON-NLS-1$
//			    
//				// set transfertype ...
//				if (binaryMode) 
//				{
//					ftpclient.setType(FTPTransferType.BINARY);
//			        if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.SetBinary")); //$NON-NLS-1$
//				}
//				else
//				{
//					ftpclient.setType(FTPTransferType.ASCII);
//			        if(log.isDetailed()) log.logDetailed(toString(), Messages.getString("JobEntryFTP.SetAscii")); //$NON-NLS-1$
//				}
//	
//				// Some FTP servers return a message saying no files found as a string in the filenlist
//				// e.g. Solaris 8
//				// CHECK THIS !!!
//				
//				if (ftpFiles.length == 1)
//				{
//					String translatedWildcard = environmentSubstitute(wildcard);
//					if(!Const.isEmpty(translatedWildcard)){
//					  if (ftpFiles[0].getName().startsWith(translatedWildcard))
//					  {
//					    throw new FTPException(ftpFiles[0].getName());
//					  }
//					}
//				}
//	
//				Pattern pattern = null;
//				if (!Const.isEmpty(wildcard)) {
//	                String realWildcard = environmentSubstitute(wildcard);
//	                pattern = Pattern.compile(realWildcard);
//				}
//				
//				if(!getSuccessCondition().equals(SUCCESS_IF_NO_ERRORS))
//					limitFiles=Const.toInt(environmentSubstitute(getLimit()),10);
//				
//				// Get the files in the list...
//				for (FTPFile ftpFile : ftpFiles) 
//				{
//					
//					if(parentJob.isStopped()){
//						exitjobentry=true;
//						throw new Exception(Messages.getString("JobEntryFTP.JobStopped"));
//					}
//					
//					if(successConditionBroken){
//						throw new Exception(Messages.getString("JobEntryFTP.SuccesConditionBroken",""+NrErrors));
//					}
//				
//					boolean getIt = true;
//					
//					String filename=ftpFile.getName();
//					if(log.isDebug()) log.logDebug(toString(), Messages.getString("JobEntryFTP.AnalysingFile",filename));
//					
//					// We get only files
//					if(ftpFile.isDir() || ftpFile.isLink()) getIt=false;
//
//					try
//					{
//						// See if the file matches the regular expression!
//						if(getIt){
//							if (pattern!=null){
//								Matcher matcher = pattern.matcher(filename);
//								getIt = matcher.matches();
//							}
//						}
//						
//						if (getIt)	downloadFile(ftpclient,filename,realMoveToFolder,log, parentJob ,result) ;
//						
//					}catch (Exception e){
//						// Update errors number
//						updateErrors();
//						log.logError(toString(),Messages.getString("JobFTP.UnexpectedError",e.getMessage()));
//					}
//				} // end for
//			}
		}
		catch(Exception e){
			//if(!successConditionBroken && !exitjobentry) updateErrors();
			//log.logError(toString(), Messages.getString("JobEntryFTP.ErrorGetting", e.getMessage())); //$NON-NLS-1$
		}
//        finally{
//            if (ftpclient!=null) {
//                try {
//                    ftpclient.quit();
//                }
//                catch(Exception e) {
//                	log.logError(toString(), Messages.getString("JobEntryFTP.ErrorQuitting", e.getMessage())); //$NON-NLS-1$
//                }
//            }
//        }
		
		//result.setNrErrors(NrErrors);
		//result.setNrFilesRetrieved(NrfilesRetrieved);
		//if(getSuccessStatus())	result.setResult(true);
		//if(exitjobentry) result.setResult(false);
		//displayResults(log);
		//return result;
		return ftpClient.connected();
	}

	private void CloseFTPConnection()
	{
		if (ftpClient!=null && ftpClient.connected()) {
          try {
              ftpClient.quit();
          }
          catch(Exception e) {
          //	log.logError(toString(), Messages.getString("JobEntryFTP.ErrorQuitting", e.getMessage())); //$NON-NLS-1$
          }
      }

	}
}