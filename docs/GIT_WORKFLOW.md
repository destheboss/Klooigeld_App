
# Git Workflow for Klooigeld

This document outlines the Git workflow and branching strategy for the Klooigeld project.

## Branching Strategy

### Main Branch
- **Purpose**: Stores the stable, production-ready code.
- **Direct Commits**: Not allowed.
- **Updates**: Only updated from the `develop` branch after successful testing.

### Develop Branch
- **Purpose**: Primary branch for integrating completed features.
- **Source of Updates**: Receives updates from `feature` branches.
- **Merging into Main**: Periodically merged into `main` after sprint completion or major release.

### Feature Branches
- **Naming Convention**: `feature/<feature-name>`
- **Purpose**: Used for individual tasks or features.
- **Creation**: Created from `develop`.
- **Merging**: Merged back into `develop` upon completion, then deleted.

## Workflow Steps

1. **Create a Feature Branch**:
   - Always create a new branch for each task or feature from `develop`.
   - Example:
     ```bash
     git checkout develop
     git checkout -b feature/new-feature
     ```

2. **Work on the Feature**:
   - Implement the feature and commit your changes regularly.
   - Commit messages should be descriptive and follow the format:
     ```
     feat(module): add new feature
     ```

3. **Merge into Develop**:
   - Once the feature is complete, merge the `feature` branch into `develop`.
   - Example:
     ```bash
     git checkout develop
     git merge feature/new-feature
     ```

4. **Merge Develop into Main**:
   - At the end of each sprint or major release, merge `develop` into `main` to update the production code.

## Commit Message Guidelines

Format:
```
<type>(<scope>): <description>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation change
- `style`: Code style update
- `refactor`: Code restructuring
- `test`: Adding tests

This workflow ensures a clean and structured development process, minimizing conflicts and maintaining code quality.
