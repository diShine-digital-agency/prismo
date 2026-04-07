# Website Performance Audit Report

**Client**: Acme Corp
**Domain**: acme.com
**Date**: 2026-04-07
**Audit Type**: Website Performance
**Prismo Version**: 1.0.0

---

## Executive Summary

The website **acme.com** shows moderate performance with several critical optimization opportunities. The overall Lighthouse performance score is **62/100** on mobile and **78/100** on desktop.

---

## Findings

### 1. Core Web Vitals

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| LCP | 4.2s | < 2.5s | 🔴 Critical |
| INP | 180ms | < 200ms | 🟢 Good |
| CLS | 0.15 | < 0.1 | 🟡 Needs improvement |

### 2. Page Weight

| Resource | Count | Size | Status |
|----------|-------|------|--------|
| JavaScript | 12 | 890 KB | 🔴 Too heavy |
| Images | 23 | 2.4 MB | 🔴 Needs optimization |
| **Total** | 43 | **3.6 MB** | 🔴 Over budget |

---

## Recommendations

1. 🔴 **Optimize images** — Convert to WebP/AVIF, add srcset
2. 🔴 **Reduce JS bundle** — Code-split, remove unused deps
3. 🟠 **Fix caching** — Add Cache-Control headers
4. 🟡 **Reduce CLS** — Add width/height to images

---

*Powered by Prismo | diShine Digital Agency | dishine.it*
