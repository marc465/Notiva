package ai.notiva.app;

import java.security.Key;
import java.util.Date;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtTokenUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long expiration;

    public String generateAccessToken(String user_id) {
        return Jwts.builder()
            .setSubject(user_id)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(getSignatureKey(), SignatureAlgorithm.HS256)
            .compact();
    }

    public String generateRefreshToken(String user_id) {
        return Jwts.builder()
            .setSubject(user_id)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + (7 * 24 * 60 * 60 * 1000)))
            .signWith(getSignatureKey(), SignatureAlgorithm.HS256)
            .compact();
    }

    public boolean validateToken(String token) {
        try {
            System.out.println(token.length());
            Jwts.parserBuilder().setSigningKey(getSignatureKey()).build().parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public Long getUserIdFromToken(String token) {
        return Long.valueOf((Jwts.parserBuilder()
            .setSigningKey(getSignatureKey())
            .build()
            .parseClaimsJws(token)
            .getBody()
            .getSubject()));
    }
    
    private Key getSignatureKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }
}
