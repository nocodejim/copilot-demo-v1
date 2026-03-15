package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@EnableWebSecurity
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf ->
                csrf.disable() // BAD: CodeQL flags this as CWE-352
            )
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**", "/h2-console/**").permitAll()
                .anyRequest().authenticated()
            )
            .headers(headers -> headers
                .frameOptions(frame -> frame.sameOrigin()) // for H2 console
            );
        return http.build();
    }
}
