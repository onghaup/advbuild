FROM $FROM$

COPY osprovision.exe C:/temp/
RUN C:/temp/osprovision.exe /qn

EXPOSE 9987/tcp
ENTRYPOINT ["C:/Program Files (x86)/Caphyon/Advanced Installer Remote Tools/RexecServerUserApp.exe"]