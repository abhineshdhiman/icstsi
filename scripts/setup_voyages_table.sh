#!/bin/bash

# Setup script for creating the voyages table in Supabase
# This script helps you run the migration easily

echo "🚢 ICSTSI Voyages Table Setup"
echo "=============================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "Please create a .env file with your Supabase credentials"
    exit 1
fi

# Load environment variables
source .env

# Check if required variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env"
    exit 1
fi

echo "📋 Migration Options:"
echo ""
echo "1. Copy SQL to clipboard (paste in Supabase Dashboard)"
echo "2. Show SQL content"
echo "3. Run using Supabase CLI (requires supabase CLI installed)"
echo ""
read -p "Choose an option (1-3): " choice

case $choice in
    1)
        # Copy to clipboard (works on macOS, Linux with xclip, or WSL)
        if command -v pbcopy &> /dev/null; then
            cat supabase/migrations/20240101000002_create_voyages_table.sql | pbcopy
            echo "✅ SQL copied to clipboard!"
            echo ""
            echo "Next steps:"
            echo "1. Go to $SUPABASE_URL/project/_/sql"
            echo "2. Paste the SQL (Cmd+V or Ctrl+V)"
            echo "3. Click 'Run' to execute"
        elif command -v xclip &> /dev/null; then
            cat supabase/migrations/20240101000002_create_voyages_table.sql | xclip -selection clipboard
            echo "✅ SQL copied to clipboard!"
            echo ""
            echo "Next steps:"
            echo "1. Go to $SUPABASE_URL/project/_/sql"
            echo "2. Paste the SQL (Ctrl+V)"
            echo "3. Click 'Run' to execute"
        else
            echo "⚠️  Clipboard tool not found. Showing SQL instead:"
            echo ""
            cat supabase/migrations/20240101000002_create_voyages_table.sql
        fi
        ;;
    2)
        echo ""
        echo "📄 SQL Migration Content:"
        echo "========================="
        cat supabase/migrations/20240101000002_create_voyages_table.sql
        ;;
    3)
        if ! command -v supabase &> /dev/null; then
            echo "❌ Error: Supabase CLI not found"
            echo ""
            echo "Install it with:"
            echo "  npm install -g supabase"
            echo "  or"
            echo "  brew install supabase/tap/supabase"
            exit 1
        fi
        
        echo ""
        echo "🔗 Linking to Supabase project..."
        read -p "Enter your Supabase project ref: " project_ref
        
        supabase link --project-ref "$project_ref"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "📤 Pushing migration to Supabase..."
            supabase db push
            
            if [ $? -eq 0 ]; then
                echo ""
                echo "✅ Migration completed successfully!"
            else
                echo ""
                echo "❌ Migration failed. Check the error above."
            fi
        else
            echo ""
            echo "❌ Failed to link to Supabase project"
        fi
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📚 For more information, see supabase/README.md"
