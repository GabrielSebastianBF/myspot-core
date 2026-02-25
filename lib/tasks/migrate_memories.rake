#!/usr/bin/env ruby
# frozen_string_literal: true

# Script para migrar memorias desde archivos Markdown a MySpot
# Uso: ruby lib/tasks/migrate_memories.rake

require 'fileutils'
require 'yaml'

class MemoryMigration
  MEMORY_DIR = '/home/lemut/.openclaw/workspace/memory'
  SCRAPE_DIR = '/home/lemut/.openclaw/workspace/memory/scrapes'
  
  def initialize(agent_id)
    @agent_id = agent_id
    @agent = Agent.find(agent_id)
    @memory_service = MemoryService.new(agent: @agent)
  end

  def run
    puts "🔄 Starting memory migration for agent: #{@agent.name}"
    
    migrate_daily_logs
    migrate_scrapes
    consolidate_short_term
    
    puts "✅ Migration complete!"
    puts "   Total memories: #{@agent.memories.count}"
  end

  private

  def migrate_daily_logs
    return unless Dir.exist?(MEMORY_DIR)
    
    Dir.glob("#{MEMORY_DIR}/*.md").each do |file|
      next if file.include?('MEMORY.md') # Skip main memory
      
      date = File.basename(file, '.md')
      content = File.read(file)
      
      # Extraer información relevante (simplificado)
      extract_memories_from_log(content, date)
    end
    
    puts "📅 Daily logs migrated"
  end

  def migrate_scrapes
    return unless Dir.exist?(SCRAPE_DIR)
    
    Dir.glob("#{SCRAPE_DIR}/*.txt").each do |file|
      content = File.read(file)
      topic = File.basename(file, '.txt')
      
      @memory_service.store(
        content,
        memory_type: :semantic,
        importance: 2,
        tags: ['scrape', topic]
      )
    end
    
    puts "📄 Scrapes migrated"
  end

  def extract_memories_from_log(content, date)
    # Parser simplificado - busca líneas con timestamps y contenido
    lines = content.split("\n")
    
    current_episode = []
    
    lines.each do |line|
      # Detectar eventos importantes
      if line.include?('**') && line.include?(':')
        # Guardar episodio anterior si existe
        if current_episode.any?
          @memory_service.store(
            current_episode.join("\n"),
            memory_type: :episodic,
            importance: 2,
            tags: ['daily-log', date]
          )
          current_episode = []
        end
        
        # Extraer evento
        event = line.gsub(/\*\*/, '').strip
        @memory_service.store(
          event,
          memory_type: :episodic,
          importance: 2,
          tags: ['event', date]
        )
      else
        current_episode << line if current_episode.any?
      end
    end
  end

  def consolidate_short_term
    @memory_service.consolidate_short_term
    puts "🔄 Short-term memories consolidated"
  end
end

# Ejemplo de uso desde Rails console:
# migration = MemoryMigration.new('uuid-del-agente')
# migration.run
