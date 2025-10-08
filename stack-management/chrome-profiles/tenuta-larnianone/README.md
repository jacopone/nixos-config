---
status: active
created: 2025-10-08
updated: 2025-10-08
type: reference
lifecycle: persistent
---

# Tenuta Larnianone Business Profile Configuration

**Profile**: Profile 1 (jacopo@tenutalarnianone.com)
**Account Type**: Corporate Domain (Potential Enterprise)
**Management Strategy**: Policy detection + user-controllable configuration

---

## 🎯 **Profile Purpose**

Dedicated business profile for Tenuta Larnianone operations:
- Business communications and email
- Company-specific web applications
- Professional document management
- Industry-specific tools and resources
- Client and supplier interactions

---

## 🔍 **Enterprise Policy Status**

### **Policy Detection Required**
⚠️ **Action Needed**: Run policy detection to determine enterprise management:

```bash
cd ~/nixos-config/stack-management/chrome-profiles/automation
python3 policy-detector.py
```

### **Expected Policy Scenarios**

#### **Scenario A: Enterprise Policies Active**
If company has Google Workspace with policies:
- ✅ **Admin-controlled**: Security, downloads, extensions (company managed)
- 🔧 **User-controllable**: Appearance, bookmarks, some preferences
- 📊 **Mixed control**: Some settings locked, others customizable

#### **Scenario B: Basic Corporate Account**
If just a domain email without enterprise policies:
- 🔧 **User-controlled**: Most settings similar to personal account
- 📧 **Company sync**: Email and calendar integration
- 🛡️ **Basic security**: Standard business practices

---

## ⚙️ **User-Controllable Settings Strategy**

### **Business-Focused Configuration**
*Note: Final configuration depends on policy detection results*

#### **Appearance & Productivity**
- **Theme**: Professional/neutral themes
- **Bookmarks**: Business websites and tools
- **Homepage**: Company intranet or business dashboard
- **New tab**: Business-focused or company page

#### **Downloads & File Management**
- **Download location**: Organized business folder structure
- **File handling**: Professional file types and security
- **Integration**: Company cloud storage if available

#### **Privacy & Security (User-Controllable Portion)**
- **Site permissions**: Business-appropriate restrictions
- **Notification preferences**: Business communications priority
- **Cookie settings**: Balance functionality with privacy

---

## 🧩 **Extension Strategy**

### **Business-Appropriate Extensions**

#### **Core Business Tools**
| Extension | Purpose | Install Method | Policy Impact |
|-----------|---------|----------------|---------------|
| **Grammarly Business** | Professional writing | Manual/Policy | May be policy-controlled |
| **LastPass Business** | Password management | Manual/Policy | Likely policy-controlled |
| **Zoom** | Video conferencing | Manual | Business necessity |
| **Microsoft Office Online** | Document editing | Manual | Business productivity |

#### **Industry-Specific Tools**
| Extension | Purpose | Notes |
|-----------|---------|-------|
| **Agricultural tools** | Industry-specific | Research needed for wine/agriculture |
| **Business analytics** | Performance tracking | Company-specific requirements |
| **Translation tools** | International business | If dealing with international clients |

#### **Professional Development**
| Extension | Purpose | Notes |
|-----------|---------|-------|
| **LinkedIn Helper** | Professional networking | Business development |
| **Invoice/Finance tools** | Business operations | Company-specific needs |

### **Extension Policy Considerations**
- **Policy-Managed**: Some extensions may be required/blocked by company
- **User Choice**: Extensions not covered by policy can be manually installed
- **Security**: All extensions must meet business security standards

---

## 📊 **Configuration Workflow**

### **Phase 1: Policy Detection**
1. **Run Policy Detector**: Use automation script to analyze current policies
2. **Export Policy Data**: Get chrome://policy export for this profile
3. **Analyze Results**: Understand what's admin vs user controlled
4. **Document Findings**: Update this README with actual policy status

### **Phase 2: User Configuration**
1. **Configure User-Controllable Settings**: Based on policy analysis
2. **Install Appropriate Extensions**: Respect policy restrictions
3. **Set Up Business Workflow**: Optimize for business use case
4. **Test Integration**: Ensure business tools work properly

### **Phase 3: Ongoing Management**
1. **Monitor Policy Changes**: Watch for company policy updates
2. **Maintain Business Focus**: Keep configuration business-appropriate
3. **Regular Reviews**: Quarterly assessment of tools and settings
4. **Security Compliance**: Ensure alignment with company standards

---

## 🛡️ **Security & Compliance**

### **Business Security Requirements**
- **Data Protection**: Sensitive business information handling
- **Access Control**: Appropriate site and service restrictions
- **Download Safety**: Enhanced caution with business files
- **Communication Security**: Secure email and messaging practices

### **Company Policy Compliance**
- **Respect Admin Policies**: Never attempt to bypass company restrictions
- **Report Issues**: Communicate policy conflicts to IT department
- **Business Use Only**: Maintain clear separation from personal activities
- **Regular Audits**: Support company security assessments

---

## 🔧 **Troubleshooting**

### **Policy-Related Issues**
1. **Settings Locked**: Contact company IT for policy clarification
2. **Extension Blocked**: Request business justification through proper channels
3. **Site Restrictions**: Work with IT for business-necessary access
4. **Sync Problems**: Verify Google Workspace configuration

### **Business Workflow Issues**
1. **Performance**: Optimize for business applications
2. **Integration**: Ensure company tools work together
3. **Access**: Resolve authentication and permission issues
4. **Compatibility**: Address business software conflicts

---

## 📋 **Action Items**

### **Immediate (This Week)**
- [ ] Run policy detection script
- [ ] Export and analyze chrome://policy data
- [ ] Document actual policy status
- [ ] Configure user-controllable settings

### **Short-term (This Month)**
- [ ] Install business-appropriate extensions
- [ ] Set up business workflow optimizations
- [ ] Test integration with company systems
- [ ] Document business use cases

### **Ongoing**
- [ ] Monthly policy status review
- [ ] Quarterly extension and settings audit
- [ ] Annual security and compliance review
- [ ] Continuous business workflow optimization

---

## 📚 **Resources**

### **Business Resources**
- **Company IT Contact**: [To be filled in]
- **Google Workspace Admin**: [To be filled in]
- **Business Application Support**: [To be filled in]

### **Technical Resources**
- **Policy Detection Script**: `../automation/policy-detector.py`
- **Chrome Enterprise Docs**: https://chromeenterprise.google/policies/
- **Business Extension Reviews**: [To be documented]

---

**Last Updated**: 2025-09-23
**Profile Status**: Awaiting policy detection
**Next Action**: Run policy detection script
**Next Review**: After policy analysis complete