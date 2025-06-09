# 🛡️ AWS Infrastructure Threat Model

## Risk Assessment Framework

### Risk Calculation
**Risk Level = Likelihood × Impact**

### Likelihood Definitions
- **High**: Happens regularly, easy to exploit, common attack vector
- **Medium**: Possible with some effort, moderate skill required  
- **Low**: Difficult to exploit, requires advanced skills/access

### Impact Definitions
- **High**: Data breach, service outage, financial loss, compliance violation
- **Medium**: Degraded performance, limited data exposure, temporary issues
- **Low**: Minor inconvenience, no data loss, easily recoverable

### Risk Matrix
| Likelihood | High Impact | Medium Impact | Low Impact |
|------------|-------------|---------------|------------|
| **High** | **HIGH RISK** | **HIGH RISK** | Medium Risk |
| **Medium** | **HIGH RISK** | Medium Risk | Low Risk |
| **Low** | Medium Risk | Low Risk | Low Risk |

---

## Threat Analysis

| What Could Go Wrong | How We Stop It | Likelihood | Impact | Risk Level |
|---------------------|----------------|------------|--------|------------|
| **Ensure that CloudWatch Log Group specifies retention days** | Follow AWS security best practices | Medium | Medium | Medium ⚠️ |
| **Ensure CloudWatch log groups retains logs for at least 1 year** | Follow AWS security best practices | Medium | Medium | Medium ⚠️ |
| **Ensure that CloudWatch Log Group is encrypted by KMS** | Follow AWS security best practices | Medium | Medium | Medium ⚠️ |

## Status Summary
- ✅ = **Implemented** (control is in place and effective)
- ⚠️ = **Needs work** (control exists but requires enhancement)
- 🔄 = **Post-launch assessment** (will evaluate after production data available)

**Current State**: 0/3 controls fully implemented, 0 deferred to post-launch
**High Risk Items**: 0 total (0 need work)
**Medium Risk Items**: 3 total (3 need work)
**Low Risk Items**: 0 total

## Next Steps
1. **Ensure that CloudWatch Log Group specifies retention days** - Follow AWS security best practices
2. **Ensure CloudWatch log groups retains logs for at least 1 year** - Follow AWS security best practices
3. **Ensure that CloudWatch Log Group is encrypted by KMS** - Follow AWS security best practices

---
*Generated from Checkov security scan on June 09, 2025*
