package org.kaltura.getftpfilenames;

import java.util.regex.Pattern;

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPConnectMode;
import com.enterprisedt.net.ftp.FTPFile;

import java.util.List;

//import org.apache.commons.vfs.FileObject;
//import org.pentaho.di.core.fileinput.FileInputList.FileTypeFilter;
import org.apache.commons.vfs.AllFileSelector;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSelectInfo;
import org.apache.commons.vfs.FileSystemException;
import org.apache.commons.vfs.FileType;
import org.apache.commons.vfs.provider.ftp.FtpFileSystemConfigBuilder;
import org.pentaho.di.core.Const;
import org.pentaho.di.core.fileinput.FileInputList;
import org.pentaho.di.core.fileinput.FileInputList.FileTypeFilter;
import org.pentaho.di.core.logging.LogWriter;
import org.pentaho.di.core.variables.VariableSpace;
import org.pentaho.di.core.vfs.KettleVFS;

public class FTPFileInputList {

	
	private static final String YES                = "Y";
	
	public int nrOfFiles() {
		// TODO Auto-generated method stub
		return 0;
	}

	public static FTPFileInputList createFileList(FTPClient ftpClient, VariableSpace space,
			String[] fileName, String[] fileMask, String[] fileRequired,
			boolean[] includeSubdirs,
			FileTypeFilter[] fileTypeFilters) {
		FileInputList fileInputList = new FileInputList();

        // Replace possible environment variables...
        final String realfile[] = space.environmentSubstitute(fileName);
        final String realmask[] = space.environmentSubstitute(fileMask);

        for (int i = 0; i < realfile.length; i++)
        {
            final String onefile = realfile[i];
            final String onemask = realmask[i];

            final boolean onerequired = YES.equalsIgnoreCase(fileRequired[i]);
            final boolean subdirs = includeSubdirs[i];
            final FileTypeFilter filter = (
                    (fileTypeFilters == null || fileTypeFilters[i] == null) ?
                            FileTypeFilter.ONLY_FILES : fileTypeFilters[i]);
            
            if (Const.isEmpty(onefile)) continue;

            // 
            // If a wildcard is set we search for files
            //
            if (!Const.isEmpty(onemask))
            {
                try
                {
                    // Find all file names that match the wildcard in this directory
                    //
                    FTPFile directoryFileObject = ftpClient.fileDetails(onefile);
                    if (directoryFileObject != null && directoryFileObject.isDir()) // it's a directory
                    {
                        FTPFile[] fullFileObjects = directoryFileObject.listFiles();
                        //List<FTPFile> fileObjects = new List<FTPFile>();
                        for (FTPFile file : fullFileObjects)
                        {
                        	
                        }
                        /*(
                                new AllFileSelector()
                                {
                                    public boolean traverseDescendents(FileSelectInfo info)
                                    {
                                        return info.getDepth()==0 || subdirs;
                                    }
                                    
                                    public boolean includeFile(FileSelectInfo info)
                                    {
                                        // Never return the parent directory of a file list.
                                        if (info.getDepth() == 0) {
                                            return false;
                                        }
                                        
                                    	FileObject fileObject = info.getFile();
                                    	try {
                                    	    if ( fileObject != null && filter.isFileTypeAllowed(fileObject.getType()))
                                    	    {
                                                String name = fileObject.getName().getBaseName();
                                                boolean matches = Pattern.matches(onemask, name);
                                                /*
                                                if (matches)
                                                {
                                                    System.out.println("File match: URI: "+info.getFile()+", name="+name+", depth="+info.getDepth());
                                                }
                                                *//*
                                                return matches;
                                    	    }
                                    	    return false;
                                    	}
                                    	catch ( FileSystemException ex )
                                    	{
                                    		// Upon error don't process the file.
                                    		return false;
                                    	}
                                    }
                                }
                            );*/
                        if (fileObjects != null) 
                        {
                            for (int j = 0; j < fileObjects.length; j++)
                            {
                                if (fileObjects[j].exists()) fileInputList.addFile(fileObjects[j]);
                            }
                        }
                        if (Const.isEmpty(fileObjects))
                        {
                            if (onerequired) fileInputList.addNonAccessibleFile(directoryFileObject);
                        }
                        
                        // Sort the list: quicksort, only for regular files
                        fileInputList.sortFiles();
                    }
                    else
                    {
                        FileObject[] children = directoryFileObject.getChildren();
                        for (int j = 0; j < children.length; j++)
                        {
                            // See if the wildcard (regexp) matches...
                            String name = children[j].getName().getBaseName();
                            if (Pattern.matches(onemask, name)) fileInputList.addFile(children[j]);
                        }
                        // We don't sort here, keep the order of the files in the archive.
                    }
                }
                catch (Exception e)
                {
                    LogWriter.getInstance().logError("FileInputList", Const.getStackTracker(e));
                }
            }
            else
            // A normal file...
            {
                try
                {
                    FileObject fileObject = KettleVFS.getFileObject(onefile);
                    if (fileObject.exists())
                    {
                        if (fileObject.isReadable())
                        {
                            fileInputList.addFile(fileObject);
                        }
                        else
                        {
                            if (onerequired) fileInputList.addNonAccessibleFile(fileObject);
                        }
                    }
                    else
                    {
                        if (onerequired) fileInputList.addNonExistantFile(fileObject);
                    }
                }
                catch (Exception e)
                {
                    LogWriter.getInstance().logError("FileInputList", Const.getStackTracker(e));
                }
            }
        }

        return new FTPFileInputList();
        //return fileInputList;
		//return null;
	}

	private static FTPFile[] GetFTPFileList(FTPClient ftpClient)
	{
		return new FTPFile[8];
	}
	public FTPFile getFile(int filenr) {
		// TODO Auto-generated method stub
		return null;
	}

	public List<FTPFile> getNonExistantFiles() {
		// TODO Auto-generated method stub
		return null;
	}

	public List<FTPFile> getNonAccessibleFiles() {
		// TODO Auto-generated method stub
		return null;
	}

	public static String getRequiredFilesDescription(
			List<FTPFileObject> nonExistantFiles) {
		// TODO Auto-generated method stub
		return null;
	}

}
