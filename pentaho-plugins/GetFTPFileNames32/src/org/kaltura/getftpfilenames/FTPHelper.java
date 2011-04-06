package org.kaltura.getftpfilenames;

import java.io.IOException;
import java.net.InetAddress;

import com.enterprisedt.net.ftp.FTPClient;
import com.enterprisedt.net.ftp.FTPException;

public class FTPHelper
{
	public static FTPClient connectToFTP(String host, int port, String user, String pw) throws IOException, FTPException
    {
		FTPClient ftpclient;

		 // Create ftp client to host:port ...
        ftpclient = new FTPClient();
        
        ftpclient.setRemoteAddr(InetAddress.getByName(host));
        ftpclient.setRemotePort(port);	                           
        
        // login to ftp host ...
        ftpclient.connect();     
        
        // login now ...
        ftpclient.login(user, pw);
        
        return ftpclient;
    }
}
