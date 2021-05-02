#!/usr/bin/env lua

require "lfs"
require "lib/file"

-- Settings
config = require "config"
if not config.inputDir then config.inputDir = arg[1] end
if not config.outputDir then config.outputDir = arg[2] end

-- Read through a directory
function handleDirectory (dir)
    for file in lfs.dir (dir) do
        local path = dir..'/'..file

        -- Ignore hidden files
        if (not isHidden (file)) then
            local attributes = lfs.attributes (path)

            if attributes.mode == "directory" then
                -- Recreate this directory in the output location
                local newDir = string.gsub (path, config.inputDir, config.outputDir)
                lfs.mkdir (newDir)

                -- Explore found directories recursively
                handleDirectory (path)
            elseif attributes.mode == "file" then
                handleFile (path)
            end
        end
    end
end

-- Decide what to do with a file based on its type
function handleFile (inputFile)
    local path = splitFilePath (inputFile)

    local file = splitFileName (path[#path])
    path[#path] = file

    local extension = file[#file]

    -- Convert Markdown files to HTML
    if extension == "md" then
        extension = "html"
        file[#file] = extension

        -- Modify path to match the output directory
        local outputFile = joinFilePath (path)
        outputFile = string.gsub (outputFile, config.inputDir, config.outputDir)

        os.execute ("pandoc -i "..inputFile.." -o "..outputFile)
        print (inputFile)
    end
end

handleDirectory (config.inputDir)
