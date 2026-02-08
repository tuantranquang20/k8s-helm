# Lab 5: Advanced Helm Features

## Objective
Learn advanced Helm templating, conditionals, loops, dependencies, hooks, and testing.

## Prerequisites
- Completed Lab 4
- Understanding of Helm chart structure
- `helm create` command knowledge

## Exercises

### Exercise 1: Create Advanced Chart
```bash
cd lab5

# Create a new chart for advanced features
helm create advanced-chart

# We'll modify this chart with advanced features
```

### Exercise 2: Conditionals
Add conditional rendering to templates. Follow instructions in `INSTRUCTIONS.md` to:
- Create a Secret template that's only created when enabled
- Use if/else statements in templates

### Exercise 3: Loops
Implement loops in templates:
- Create ConfigMap with dynamic entries using range
- Loop through environment variables

### Exercise 4: Template Functions
Practice template functions:
- String manipulation (upper, lower, replace)
- Default values
- Type conversions

### Exercise 5: Named Templates (Helpers)
Create custom helper functions:
- Database connection string generator
- Custom label generators

### Exercise 6: Chart Dependencies
Add dependencies to your chart:
- Add PostgreSQL dependency
- Add Redis dependency
- Manage dependencies with conditions

### Exercise 7: Helm Hooks
Implement lifecycle hooks:
- Pre-install job
- Post-install job
- Test hooks

### Exercise 8: Chart Testing
Create and run chart tests:
- Connection test
- Service availability test

### Exercise 9: Cleanup
```bash
# Uninstall all releases
helm uninstall advanced-release
helm uninstall advanced-with-deps

# Clean up test pods
kubectl delete pods -l helm.sh/chart-test=true
```

## Checkpoints
- [ ] Used conditionals in templates
- [ ] Implemented loops for dynamic values
- [ ] Applied template functions
- [ ] Created custom named templates
- [ ] Added chart dependencies
- [ ] Implemented Helm hooks
- [ ] Created and ran chart tests
- [ ] Cleaned up all resources

## Files to Create/Modify
See `INSTRUCTIONS.md` for detailed guidance on:
- Creating conditional templates
- Implementing loops
- Adding dependencies
- Creating hooks
- Writing tests

## Advanced Challenges

### Challenge 1: Multi-condition Logic
Create a template that uses multiple conditions to determine:
- Which storage class to use
- What ingress annotations to apply
- Security context based on environment

### Challenge 2: Complex Loops
Create a template that:
- Loops through multiple environment variables
- Supports both ConfigMap and Secret sources
- Handles optional values gracefully

### Challenge 3: Custom Helper Library
Build a `_helpers.tpl` with:
- Database URL generator
- Redis URL generator
- Environment-based resource calculator

## Next Steps
After completing this lab, you're ready for:
- Real-world Helm chart development
- Contributing to public Helm charts
- Deploying production applications with Helm

Congratulations on completing all labs! 🎉
