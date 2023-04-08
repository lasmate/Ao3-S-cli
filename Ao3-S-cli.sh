#!/bin/sh

menu_select(){ #creates a menu based on the function that calls it 
    #only for prototypyng/future use 
    echo "select $1"
    ans1=$(printf '%s\n' "${$2}" | fzf --color='fg:111,info:159,border:134' --border --height=10% --cycle | awk '{printf $1}')
    # cut -d ' ' -f 0 is the first element(empty in this case) in the list so the first element is 1
    $3 $ans1

}
###MINI FUNCTIONS###
quit(){ #functional
    echo "exiting"
    exit 0
}
 error (){ #functional
    echo "invalid input"
    exit 1
}

### SEARCH FUNCTIONS ###
search_author(){ #functional
    echo "input author name"
    read -p "> " author_name
    author_list_raw=$(curl -s https://archiveofourown.org/people/search?people_search%5Bname%5D=$author_name |grep -Eoi '"/users[^\"]+"') 
    author_list=$(echo $author_list_raw |sed 's/\"//g'|tr ' ' '\n' |tr '/' '\n'| sort -u |tr '\n' ' '| sed 's/users//g'|sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/pseuds//g') 
    author_id=$(printf '%s\n' ${author_list} | fzf --color='fg:111,info:159,border:134' --border --height=10% --cycle | awk '{printf $1}')    
    select_work $author_id

}
search_tag(){ #non functional
    echo "input tag name"
    read -p "> " tag_name
    tag_list_untreated=$(curl -s https://archiveofourown.org/tags/search?tag_search%5Bname%5D=$tag_name&tag_search%5Bsort_direction%5D=asc&commit=Search+Tags |grep -Eoi '"/works[^\"]+"') 
    tag_list_sanitised=$(echo $tag_list_untreated |sed 's/login//g' |sed 's/password//g'|sed 's/new//g' | sed 's/users\///g') #removes any unwanted strings from the list
    if [tag_list_sanitised != " "];then
        echo "works found under $tag_name"
        for i in tag_list_sanitised; do
            work_name_temp=$(https://archiveofourown.org/tags/$tag_name/works  grep -oP '(?<=<h2 class="title heading">)[\s\S]+(?=</h2>)' | sed 's/\"//g')
            echo $i
        done
    fi
}
search_work(){ #non functional
    # if have the feeling having a separate function to search only works might be very useless butg a refactor seems dumb until most othe funcs are coded AND work 
    echo "input work name"
    read -p ":: " work_name


}
### SELECT FUNCTIONS ###
select_work(){ #functional
    work_list=$(curl -s https://archiveofourown.org/users/$author_id/works | grep -Eoi '/works/[0-9]+">[^<]+'|sed 's/\"//g'|sed 's/works//g'|sed 's/ /_/g'|sed 's/\/\///g'| sed 's/</ /g'|tr '\n' ' ')
    #creates a list and sanitises the output into rows on this format "[number]>work_name"
    work_id_raw=$(printf '%s\n' ${work_list} | fzf --color='fg:111,info:159,border:134' --border --height=10% --cycle |awk '{printf $1}')
    work_id=$(echo $work_id_raw |sed 's/>/ /g' |cut -d ' ' -f 1)
    echo "selected work $work_id_raw with $work_id as its id"
    Pmode=$(printf '%s\n' "Read" "Download" "Back" | fzf --color='fg:111,info:159,border:134' --border --height=10% --cycle)
    case $Pmode in
        Read)  
            select_chapter $work_id;;
        Download) 
            dl_work $work_id;;
        Back)
            search_author;;
        *)
            error;;
    esac

}
select_chapter(){ #future me this is very redundant and bloated please find a way to clean it up
    work_id=$1
    chapter_raw=$(curl -s https://archiveofourown.org/works/$work_id/navigate |grep -Eoi 'chapters/[0-9]+">[0-9]+. [^<]+</a> <span class="datetime">[^<]+' | sed 's/<li><a href="\/works//g'| sed 's/<\/a> <span class="datetime">//g' | sed 's/<\/li>//g' | sed 's/chapters//g' | tr '">' ' ')
    chapter_list_id=$(echo $chapter_raw | cut -d ' ' -f 1 | tr '\n' ' ' |sed 's/\///g')
    chapter_list_names=$(echo $chapter_raw| cut -d ' ' -f 4- | tr ' ' '_')
    
    inc=1
    for i in $chapter_list_names; do
        echo $inc $i
        inc=$((inc+1))
    done
    echo " select chapter"
    echo " type q to quit"
    read -p ":: " arg
    while [ $arg != "q" ]; do
        if [ $arg -gt $inc ]; then
             error j
        else
            chapter_id=$(echo $chapter_list_id | cut -d ' ' -f $arg)
            chapter_name=$(echo $chapter_list_names | cut -d ' ' -f $arg)
            scrape_chapter $work_id $chapter_id $chapter_name
        fi
    done
}

### menu functions ###
chapter_resume(){
    #in construction 
    #resumes chapter and works from hist file
    echo "resuming last chapter"
}
chapter_read(){
    #in construction
    #reads chapter of current work
    echo "reading last chapter"
}
chapter_next(){
    #in construction
    #reads next chapter of current work
    echo "reading next chapter"
}
chapter_previous(){
    #in construction
    #reads previous chapter of current work
    echo "reading previous chapter"
}

### DOWNLOAD FUNCTIONS ###
dl_work(){ #functional bc of implemented dl method in the base website
    work_id=$1
    work_name_web=$(curl https://archiveofourown.org/works/$work_id | grep -oP 'ks/[0-9]+">[\s\S]+</a>' |sed 's/ks\///g'| sed 's/<\/a>//g' |sed -e 's/ /%20/g'|tr '">' ' ' | cut -d ' ' -f 2-)
    echo $work_name_web
    semilink="$work_id/$work_name_web"
    semilink=$(echo $semilink | sed -e 's/ //g')
    echo $semilink
    echo "downloading work"

    aria2c https://archiveofourown.org/downloads/$semilink.pdf
    exit 0
}
dl_chapter(){ #non functionnal, requiresnuch more work to dl specific chapters and not the whole work
    work_id=$1
    chapter_id=$2
    chapter_name=$3
    chapter_name_web=$(echo $chapter_name |tr '_' '%20')
    echo "scraping chapter $chapter_id"
    wget -q https://archiveofourown.org/download/$work_id/$ -O chapter
}

### START MENU ###
echo "Search for"
arg=$(printf '%s\n' "Work" "Author" "Tag" "Resume" "Help" "Quit" "Test" |fzf  --color='fg:111,info:159,border:134' --border --height=10% | awk '{print $1}')
case $arg in
    Resume)
        resume;;
    Work)
        search_work;;
    
    Author) 
        search_author;;
    Tag) 
        search_tag;;
    Help)
        echo "availiable options : w,t,a,h,q
        -r : resume last chapter
        -w : search for a work
        -t : search for a tag
        -a : search for an author
        -h : help";;
    Quit)
        exit 1;;
    Test) # DLdebug
        echo "test"
        dl_work 41540862
        ;;
    *)
        error;;
esac