#!/bin/bash
# publish-homebrew.sh - Helper script to publish Recall to Homebrew

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n${BLUE}🍺 Homebrew Publishing Script for Recall${NC}\n"

# Configuration
GITHUB_USER="josharsh"
REPO_NAME="recall"
TAP_REPO="homebrew-tap"
VERSION="v0.1.0"

# Step 1: Check if main repo exists on GitHub
echo -e "${YELLOW}Step 1: Checking GitHub setup...${NC}"

if git remote get-url origin &>/dev/null; then
  REMOTE_URL=$(git remote get-url origin)
  echo -e "${GREEN}✓${NC} Remote origin exists: $REMOTE_URL"
else
  echo -e "${YELLOW}⚠${NC}  No remote 'origin' found"
  echo -e "\n${BLUE}To create GitHub repo, run:${NC}"
  echo -e "  gh repo create ${GITHUB_USER}/${REPO_NAME} --public --source=. --remote=origin"
  echo -e "  git push -u origin main"
  exit 1
fi

# Step 2: Check if version tag exists
echo -e "\n${YELLOW}Step 2: Checking version tag...${NC}"

if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Tag $VERSION exists"
else
  echo -e "${YELLOW}⚠${NC}  Tag $VERSION doesn't exist"
  echo -e "\n${BLUE}To create tag, run:${NC}"
  echo -e "  git tag -a $VERSION -m 'Release $VERSION'"
  echo -e "  git push origin $VERSION"
  exit 1
fi

# Step 3: Calculate SHA256 of release tarball
echo -e "\n${YELLOW}Step 3: Calculating SHA256 for release tarball...${NC}"

TARBALL_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/archive/refs/tags/${VERSION}.tar.gz"
echo -e "Downloading: $TARBALL_URL"

SHA256=$(curl -sL "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')

if [ -z "$SHA256" ]; then
  echo -e "${RED}✗${NC} Failed to calculate SHA256"
  echo -e "\nMake sure you created a GitHub release for $VERSION"
  echo -e "Visit: https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/new"
  exit 1
fi

echo -e "${GREEN}✓${NC} SHA256: $SHA256"

# Step 4: Update Formula with SHA256
echo -e "\n${YELLOW}Step 4: Updating formula with SHA256...${NC}"

FORMULA_FILE="Formula/recall.rb"

if [ ! -f "$FORMULA_FILE" ]; then
  echo -e "${RED}✗${NC} Formula file not found: $FORMULA_FILE"
  exit 1
fi

# Replace placeholder with actual SHA256
sed -i.bak "s/PLACEHOLDER_UPDATE_AFTER_GITHUB_RELEASE/$SHA256/" "$FORMULA_FILE"
rm -f "${FORMULA_FILE}.bak"

echo -e "${GREEN}✓${NC} Formula updated with SHA256"

# Step 5: Show next steps
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓  Formula Ready for Homebrew Tap!              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Next steps:${NC}\n"

echo -e "1. ${YELLOW}Create homebrew-tap repository:${NC}"
echo -e "   gh repo create ${GITHUB_USER}/${TAP_REPO} --public"
echo -e "   cd .. && git clone git@github.com:${GITHUB_USER}/${TAP_REPO}.git"
echo -e ""

echo -e "2. ${YELLOW}Copy formula to tap repo:${NC}"
echo -e "   cd ${TAP_REPO}"
echo -e "   mkdir -p Formula"
echo -e "   cp ../recall/Formula/recall.rb Formula/"
echo -e ""

echo -e "3. ${YELLOW}Push to tap repository:${NC}"
echo -e "   git add Formula/recall.rb"
echo -e "   git commit -m 'Add Recall formula ${VERSION}'"
echo -e "   git push origin main"
echo -e ""

echo -e "4. ${YELLOW}Test installation:${NC}"
echo -e "   brew install ${GITHUB_USER}/tap/recall"
echo -e "   recall help"
echo -e ""

echo -e "5. ${YELLOW}Update README.md:${NC}"
echo -e "   Add installation instructions for Homebrew"
echo -e ""

echo -e "${GREEN}Users can then install with:${NC}"
echo -e "  brew install ${GITHUB_USER}/tap/recall"
echo -e ""

echo -e "${BLUE}Formula details:${NC}"
echo -e "  URL: $TARBALL_URL"
echo -e "  SHA256: $SHA256"
echo -e "  Version: $VERSION"
echo -e ""