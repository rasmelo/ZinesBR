/*
 * Copyright (c) 2004 Motd Laboratories.  All rights reserved.
 *
 * For more information, please visit http://www.motdlabs.org
 *
 * --
 *
 *  Steganography with HTML
 *
 *  Usage: ./steno -[hs] <html file> <data file> [steno file]
 *         -h           hide data file in html file
 *         -s           show hidden data
 *
 * 
 *  Ex.:
 *       wget http://narcotic.motdlabs.org/index.html
 *       ./steno -s index.html steno.txt
 *       cat steno.txt
 * --
 *
 * Narcotic
 * narcotic@motdlabs.org
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#ifndef false
  #define false 0
  #define true !false
#endif


int msgSize;

/*
 * alphabet: white space (0x20) bit off
 *           tab         (0x13) bit on
 *           new line    (0x0A) new byte
 */
char *show(unsigned char *buff,unsigned int *nsize)
{
        char *ret, *tmp  = (char *)malloc(*nsize >> 3);
        int pos, count;
        char byte, ignore;

        byte = pos = count = 0;
        ignore = false;
        
        while(*buff++)
        {
                switch(*buff)
                {
                        case '\t': byte |= 1 << count++; break;
                        case  ' ':              count++; break;
                        case '\n': count = 0; byte = 0;  break;
                        
                        /* <pre> </pre> ? */
                        case  '<': if(strncmp(buff,"<pre>",5) == 0)
                                       ignore = true;
                                   else if(ignore && strncmp(buff,"</pre>",6) == 0)
                                        ignore = false;
                                   break;
                }
                
                if(count == 8 && !ignore)
                {
                        tmp[pos++] = byte;
                        count = 0;
                        byte  = 0;
                }
        }
        
        ret = (char *)malloc(pos);
        
        memcpy(ret,tmp,pos);
        free(tmp);
        
        *nsize = pos;
        return ret;
}

char *hide(unsigned char *buff, unsigned char *info, unsigned int nsize)
{
        char *tmp = (char *)malloc((nsize << 3) + strlen(buff) + 1);
        char *ret;
        char ignore, nl = '\n';
        unsigned int count, pos, i, j;
        
        count = pos = 0;
        
        while(*buff)
        {
                if(nsize)
                {
                        switch(*buff)
                        {
                                case '\t':
                                case  ' ': if((*info >> count) & 1)
                                                tmp[pos++] = '\t';
                                           else
                                                tmp[pos++] = ' ';
                                           count++;
                                           break;
                                
                                case '\r': nl = '\r';
                                case '\n': if(count && count < 8)
                                           {
                                                for(i = count; i < 8; i++)
                                                {
                                                        if((*info >> i) & 1)
                                                                tmp[pos++] = '\t';
                                                        else
                                                                tmp[pos++] = ' ';
                                                }
                                                info++;
                                                nsize--;
                                            }
                                            
                                            tmp[pos++] = nl;
                                            count = 0;
                                            
                                            nl = '\n';
                                            break;
                                            
                                case '<': if(strncmp(buff,"<pre>",5) == 0)
                                                ignore = true;
                                          else if(ignore && strncmp(buff,"</pre>",6) == 0)
                                                ignore = false;
                                                
                                default: tmp[pos++] = *buff;
                        }
                                  
                        if(count == 8)
                        {
                                count = 0;
                                info++;
                                nsize--;
                        }
                }
                else
                {
                        switch(*buff)
                        {
                                case  ' ': 
                                case '\t': count++; break;
                                case '\r':
                                case '\n': count = 0; break;
                                case  '<': if(strncmp(buff,"<pre>",5) == 0)
                                                ignore = true;
                                          else if(ignore && strncmp(buff,"</pre>",6) == 0)
                                                ignore = false;
                                          break;
                        }
                                
                        if(!ignore && count == 7)
                        {
                                tmp[pos++] = '\n';
                                count = 0;
                        }
                        
                        tmp[pos++] = *buff;
                }
                
                buff++;
        }
        
        if(nsize)
        {
                for(i = 0; i < nsize; i++)
                {
                        for(j = 0; j < 8; j++)
                        {
                                if((*info >> j) & 1)
                                        tmp[pos++] = '\t';
                                else
                                        tmp[pos++] = ' ';
                        }
                        info++;
                }
        }
        
        ret = (char *)malloc(pos);
        
        memcpy(ret,tmp,pos);
        free(tmp);

        return ret;
}

int readfile(char *fname, char **data)
{
        FILE *fp;
        int  fsize, n;

        fp = fopen(fname,"rb");
        
        if(!fp)
                return -1;
        
        fseek(fp,0L,SEEK_END);
        fsize = ftell(fp);
        rewind(fp);
        
        *data = (char *)malloc(fsize);
        
        if(*data == NULL)
                return -2;
                
        n = fread (*data, fsize, 1, fp);
        
        fclose(fp);
        
        if(n == -1)
                return -3;
                
        return fsize;
}

int save(char *fname,char *data,int len)
{
        FILE *fp;

        fp = fopen(fname,"wb");
        
        if(!fp)
                return -1;
        
        fwrite(data,len,1,fp);
        fclose(fp);
        
        return 0;
}

void CopyRight()
{
    printf("Steganography HTML ver 0.1\n");
    printf("Copyright (c) 2004 Motd Laboratories.  All rights reserved.\n");
}


void Usage()
{
        printf("./steno -[hs] <html file> <data file> [steno file]\n");
        printf("-h              hide data file in html file\n");
        printf("-s              show hidden data\n\n");
}

int main(int argc, char **argv)
{
        char *info, *datafile, *fname;
        char *steno;
        int len, len2;
        
        CopyRight();
        
        if(argc != 4 && argc != 5)
        {
                Usage();
                return 1;
        }
        else if(argc == 4)
                fname = argv[3];
        else
                fname = argv[4];
        
        if(argv[1][0] == '-')
        {
                switch(argv[1][1])
                {
                        /* hide information */
                        case 'h': len  = readfile(argv[2],&datafile);
                                  len2 = readfile(argv[3],&info);
                                  
                                  steno = hide(datafile,info,len2);
                                  save(fname,steno,strlen(steno));
                                  break;
                                  
                        /* show information */
                        case 's': len   = readfile(argv[2],&datafile);
                                  len2  = len;
                                  
                                  steno = show(datafile,&len2);
                                  save(fname,steno,len2);
                                  break;
                                  
                        default: Usage();
                                 break;
                }
        }
        else
        {
                Usage();
        }
        
        return 0;
}
