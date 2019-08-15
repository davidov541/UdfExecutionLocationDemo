package com.test.hadoop;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;

import java.net.InetAddress;
import java.net.UnknownHostException;

// Description of the UDF
@Description(
        name="GetHostname",
        value="Returns the host name on which the UDF is running..",
        extended="select getHostname() from hivesampletable limit 10;"
)
public class GetHostname extends UDF {
    // Accept a string input
    public String evaluate() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            return "Unknown";
        }
    }
}