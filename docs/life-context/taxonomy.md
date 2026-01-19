---
status: active
created: 2026-01-16
updated: 2026-01-16
type: reference
lifecycle: persistent
---

# Life Context Taxonomy

## Life Domains (3 domains)

| Domain | Tag | Covers |
|--------|-----|--------|
| **Family & Friends** | `#family` | Partner, children, extended family, friends |
| **Work** | `#work` | Liberis, consulting, professional commitments |
| **Self** | `#self` | Health, personal growth, hobbies, self-care |

### Why 3 Domains?

- **Family & Friends**: Relationships cluster naturally - your spouse, kids, and parents often share calendar impact
- **Work**: Income-generating and professional responsibilities are distinct
- **Self**: Your own health, growth, and recovery is separate from caring for others

### Cross-Domain Entities

People can belong to multiple domains. Tag them accordingly:
- `@Marco [friend, work]` - appears in both contexts
- `@Dr.Rossi [health, family]` - treats you and your kids

---

## Commitment Types (MECE)

Every commitment is exactly ONE of these types:

| Type | Symbol | Definition | Example |
|------|--------|------------|---------|
| **Event** | 📅 | Has a specific date/time | "Doctor appointment Jan 22 2pm" |
| **Task** | ☐ | Action I must take, flexible timing | "Send proposal to Sergio" |
| **Waiting** | ⏳ | Blocked on someone/something | "Waiting: budget approval from Finance" |
| **Ongoing** | ♻️ | Recurring, no end date | "Gym 3x/week" |

### Why MECE?

MECE = Mutually Exclusive, Collectively Exhaustive

- Every commitment fits exactly one type
- No overlap, no gaps
- Makes filtering and querying unambiguous

---

## Entity Notation

### People
Use `@Name` notation:
```
- 📅 2026-01-20 | Dinner | @Mom @Dad
- ⏳ Waiting: decision from @Partner
```

### Tags
Use `#domain` notation:
```
/life add dinner Friday with Marco #family
/life add quarterly review deadline #work
```

### Relationship Tags (for entities)
```
@Marco [friend, work]
@Dr.Rossi [health, family]
@School [children, institution]
```

---

## Energy Levels

Track domain energy with emoji:

| Emoji | Meaning |
|-------|---------|
| 🟢 | Good - normal capacity |
| 🟡 | Moderate - some strain |
| 🔴 | Draining - needs attention |

Example:
```
Family: 🟢 | Work: 🟡 | Self: 🟢
```

---

## Waiting-For Format

| What | Who | Since | Blocks |
|------|-----|-------|--------|
| Vacation dates | @Partner | Jan 10 | Work PTO request |
| Budget approval | @Finance | Jan 12 | Project kickoff |

Key fields:
- **What**: The item you're waiting for
- **Who**: The person/entity blocking
- **Since**: When you started waiting (for aging)
- **Blocks**: What other commitment this blocks (ripple effect)
