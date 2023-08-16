const   UP0 = 1, 
        UP1 = 256, 
        UP2 = UP1*UP1, 
        UP3 = UP2*UP1,
        UP4 = UP3*UP1,
        UP5 = UP4*UP1,
        UP6 = UP5*UP1,
        UP7 = UP6*UP1;
let     SYSID,
        SEGSIZE,
        BLOCKSIZE;
function readXLogPageHeaderData(str){
    let xlp_magic, xlp_info, xlp_tli, xlp_pageaddr, xlp_rem_len, xlp_sysid, xlp_segsize, xlp_xlog_blcksz, returnPtr = 24;
    xlp_magic = read2ByteInt(str, 0);
    xlp_info = read2ByteInt(str, 2);
    xlp_tli = read4ByteInt(str, 4);
    xlp_pageaddr = read8ByteInt(str, 8);
    xlp_rem_len = read4ByteInt(str, 16);
    /* padding 4 bytes */
    if((xlp_info / 2) % 2 == 1){
        xlp_sysid = read8ByteInt(str, 24);
        xlp_segsize = read4ByteInt(str, 32);
        xlp_xlog_blcksz = read4ByteInt(str, 36);
        SYSID = xlp_sysid;
        SEGSIZE = xlp_segsize;
        BLOCKSIZE = xlp_xlog_blcksz;
        returnPtr = 40;
    }
    return returnPtr;
}
function read8ByteInt(str, i) {
    return (str.charCodeAt(i)*UP0 + str.charCodeAt(i+1)*UP1 + str.charCodeAt(i+2)*UP2 + str.charCodeAt(i+3)*UP3 + 
            str.charCodeAt(i+4)*UP4 + str.charCodeAt(i+5)*UP5 + str.charCodeAt(i+6)*UP6 + str.charCodeAt(i+7)*UP7);
}
function read4ByteInt(str, i) {
    return (str.charCodeAt(i)*UP0 + str.charCodeAt(i+1)*UP1 + str.charCodeAt(i+2)*UP2 + str.charCodeAt(i+3)*UP3);
}
function read2ByteInt(str, i) {
    return (str.charCodeAt(i)*UP0 + str.charCodeAt(i+1)*UP1);
}
function splitString(str, chunk) {
    const result = [];
    for (let i = 0; i< str.length; i += chunk) {
        let temp;
        temp = str.substr(i, i + chunk);
        result.push(temp);
    }
    return result;
}
function resultToBuffer(result){
    let length, length_save;
    readXLogPageHeaderData(result);
    const pages = splitString(result, BLOCKSIZE);
    result = null;
    for(let ptr = 0; ptr<SEGSIZE;) {
        let page = parseInt(ptr / BLOCKSIZE);
        if(ptr % BLOCKSIZE == 0) {
            ptr += readXLogPageHeaderData(pages[page]);
        }
        length = read4ByteInt(pages[page], ptr % 8192);
        if(length == 0) return;
        else if(length % 8 != 0) {
            length_save = length;
            length = (parseInt(length / 8) + 1) * 8;
        }
        let resultArray = [];
        for(let task = 0; task < length; task++){
            page = parseInt(ptr / BLOCKSIZE);
            let now = ptr % BLOCKSIZE;
            if(now == 0){
                page = parseInt(ptr / BLOCKSIZE);
                ptr += readXLogPageHeaderData(pages[page]);
                now = ptr % BLOCKSIZE;
            }
            resultArray.push(pages[page].charCodeAt(now));
            ptr++;
            
        }
        const table = document.createElement("table");
        for(let i = 0; i < length_save; i+=16) {
            const tableRow = document.createElement("tr");
            for(let j = 0; j < 16; j++) {
                const tableData = document.createElement("td");
                var temp = parseInt(resultArray[i+j]);
                if(i+j < resultArray.length) {
                    tableData.innerText = (temp<16)?"0"+temp.toString(16) :temp.toString(16);

                }
                tableData.style = 'border: 1px solid #444444';
                tableData.style.width = '40px'
                tableRow.appendChild(tableData);
            }
            table.appendChild(tableRow);
        }
        table.style = "border: 1px solid #444444"
        document.querySelector("#result").appendChild(table);
        console.log(resultArray);
        resultArray = null;
    }
}
document.querySelector("#read").addEventListener('click', function() {
    let filename, file, reader, n=0, result, blob;
    if(document.querySelector("#file").value == '') {
        alert('No file selected');
        return;
    }
    file = document.querySelector("#file").files[0];
    reader = new FileReader();
    reader.onloadend = function(e) {
        // console.log(e.target.result);
        resultToBuffer(e.target.result);
    };
    reader.onerror = function(e) {
        alert('Error: '+e.type);
    }
    reader.readAsBinaryString(file);
});