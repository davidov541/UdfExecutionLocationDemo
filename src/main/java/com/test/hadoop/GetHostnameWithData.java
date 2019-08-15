package com.test.hadoop;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;

import java.net.InetAddress;
import java.net.UnknownHostException;

// Description of the UDF
@Description(
        name="GetHostnameWithData",
        value="Returns the host name on which the UDF is running, along with a string passed into the function.",
        extended="select getHostnameWithData(col1) from hivesampletable limit 10;"
)
public class GetHostnameWithData extends UDF {
    // Accept a string input
    public String evaluate(String data) {
        try {
            return InetAddress.getLocalHost().getHostName() + " " + data;
        } catch (UnknownHostException e) {
            return "Unknown " + data;
        }
    }
}