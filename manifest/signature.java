package manifest;

package com.freewayemi.payment.test;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class ShopSeSignatureTest {

    public static void main(String[] args)
            throws NoSuchAlgorithmException, InvalidKeyException, UnsupportedEncodingException {
        String hashKey = "7mti39lmds9o2rlpplw29zmaicdq11";
        String signatureData = "currentTime%3D1622202511414%26orderId%3D20284168372393%26shopSeTxnId%3DS28052111463540078%26status"
                +
                "%3Dsuccess%26statusCode%3D0%26statusMessage%3DTransaction+successful";
        String shopSeSignature = "uOclu7dWrLQSeXU ltdjydDmNMG/xfeirlqoZVqAm c=";
        System.out.println("shopSeSignature: " + shopSeSignature);
        String computedSignature = Base64.getEncoder().encodeToString(getHmacSha256Bytes(hashKey, signatureData));
        System.out.println("Base 64 encoded computedSignature: " + computedSignature);

        String shopSeUrlEncodedSignature = URLEncoder.encode(shopSeSignature, "UTF-8");
        System.out.println("URL encoded shopSeUrlEncodedSignature: " + shopSeUrlEncodedSignature);

        String ourCalculatedEncodedSignature = URLEncoder.encode(computedSignature, "UTF-8");
        System.out.println("URL encoded ourCalculatedEncodedSignature: " + ourCalculatedEncodedSignature);

        String urlDecodedSignature = URLDecoder.decode(computedSignature, "UTF-8");
        System.out.println("urlDecodedSignature: " + urlDecodedSignature);
    }

    private static byte[] getHmacSha256Bytes(String secretKey, String data)
            throws NoSuchAlgorithmException, InvalidKeyException {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(secretKey.getBytes(), "HmacSHA256");
        mac.init(secretKeySpec);
        return mac.doFinal(data.getBytes());
    }
}
