function getPathToBibFile(file)
    -- Return complete path to LaTeX file
    local handle = io.popen('kpsewhich ' .. file)
    local bibEntry = handle:read("l")
    handle:close()
    return bibEntry
end


function fixYAMLHeader(meta)
    if FORMAT ~= 'latex' then  -- Need to cope with csl style....
        if meta.csl then  -- Use the one that's provided if it is
            meta.csl[1].c = string.gsub(meta.csl[1].c, "~", os.getenv('HOME'))
        elseif not meta.csl then  -- otherwise choose inline or notes style.
            local intextCSL = os.getenv('HOME') .. '/.pandoc/chicago-manual-of-style-16th-edition-full-in-text.csl'
            local notesCSL = os.getenv('HOME') .. '/.pandoc/chicago-fullnote-bibliography.csl'
            if meta.bibinline then
                meta.csl = pandoc.MetaInlines(pandoc.Str(intextCSL))
            else
                meta.csl = pandoc.MetaInlines(pandoc.Str(notesCSL))
            end
        end
    end
    if meta.geometry and meta.geometry[1].c == 'ipad' then
        if meta.book then
            meta.geometry[1].c = 'paperwidth=176mm,paperheight=234mm,outer=22mm,top=2.5pc,bottom=3pc,headsep=1pc,includehead,includefoot,centering,inner=22mm,marginparwidth=17mm'
        else
            meta.geometry[1].c = 'paperwidth=176mm,paperheight=234mm,width=360.0pt,height=541.40024pt,headsep=1pc,centering'
        end
    end
    if meta.bibliography then  -- Get complete path to bibliography files
        if meta.bibliography.t == "MetaList" then
            for key, value in pairs(meta.bibliography) do
                meta.bibliography[key][1].c = getPathToBibFile(value[1].c)
            end
        elseif meta.bibliography.t == "MetaInlines" then
            meta.bibliography[1].c = getPathToBibFile(meta.bibliography[1].c)
        end
    end
    return meta
end


return {
    {Meta = fixYAMLHeader},   -- Minor fixes to document metadata
}