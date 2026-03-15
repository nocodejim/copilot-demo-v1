package com.example.demo.controller;

import com.example.demo.model.NaicsCode;
import com.example.demo.repository.NaicsCodeRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * REST controller for NAICS code lookups.
 * All endpoints are under /api/public/ to bypass Spring Security for demo purposes.
 */
@RestController
@RequestMapping("/api/public/naics")
public class NaicsController {

    private final NaicsCodeRepository repository;

    public NaicsController(NaicsCodeRepository repository) {
        this.repository = repository;
    }

    /**
     * Get all NAICS codes, optionally filtered by hierarchy level.
     */
    @GetMapping
    public List<NaicsCode> getAll(@RequestParam(required = false) Integer level) {
        if (level != null) {
            return repository.findByLevel(level);
        }
        return repository.findAll();
    }

    /**
     * Look up a specific NAICS code.
     */
    @GetMapping("/{code}")
    public ResponseEntity<NaicsCode> getByCode(@PathVariable String code) {
        return repository.findByCode(code)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Search NAICS codes by title keyword.
     */
    @GetMapping("/search")
    public List<NaicsCode> search(@RequestParam String q) {
        return repository.findByTitleContainingIgnoreCase(q);
    }

    /**
     * Get all codes under a sector prefix (e.g., "51" returns all IT codes).
     */
    @GetMapping("/sector/{prefix}")
    public List<NaicsCode> getBySector(@PathVariable String prefix) {
        return repository.findByCodeStartingWith(prefix);
    }
}
