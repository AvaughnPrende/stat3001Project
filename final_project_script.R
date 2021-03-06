#------------------------------------------------Instructions-------------------------------------------------------
# 1. Ensure you have loaded the dataset already. Also the variables need to be labled by name (age, hright hip, etc).
#    The first script will do this automatically. So you can just load that. 
# 2. Download the 'binaryLogic' package. 
# 3. If you have not yet done so, download the 'xlsx' package.
# 4. If all the data is properly loaded, and the relevant packages have been installed, you may copy and run the code. 
# 5. It may take a few seconds to complete. After the code has ran, navigate to the directory you're in and open the 
#    'subset models test.xlsx' file. 
# 6. Please run a few tests to ensure the correct answers are being spit out by the algorithm. 
# 7. Have fun! 

library(xlsx);
library(binaryLogic);

#Relabel the variables
x1<-list(age,'x1');
x2<-list(height,'x2');
x3<-list(ankle,'x3');
x4<-list(abdomen,'x4');
x5<-list(forearm,'x5');
x6<-list(wrist,'x6');

list_of_predictors<- list(x1,x2,x3,x4,x5,x6);

get_model_name<-function(linear_model){
	coefficients<-variable.names(linear_model);
	return (paste0(coefficients[-1],collapse = ','))
}

get_model_summary<-function(linear_model){
	model_summary <- summary(linear_model);
	analysis_of_variance <- anova(linear_model);
	model_name<-get_model_name(linear_model);
	rss<-analysis_of_variance['Sum Sq'][[1]][[length(analysis_of_variance[[1]])]];
	k<-length(analysis_of_variance[[1]]);
	p<-as.integer(k)-1;
	n<-model_summary['df'][[1]][[2]] + k;
	s_squared<-model_summary['sigma'][[1]]**2;
	r_squared<-model_summary['r.squared'][[1]];
	adjusted_r_squared<-model_summary['adj.r.squared'][[1]];
	
	return(c(list(
			model_name,
			as.double(rss),
			as.double(p),
			as.double(k),
			as.double(n),
			as.double(s_squared),
			as.double(r_squared),
			as.double(adjusted_r_squared))));
}


AIC<-function(linear_model){
	model_summary<-get_model_summary(linear_model);
	rss<-model_summary[[2]];
	n<-model_summary[[5]];
	p<-model_summary[[3]];
	aic<-(n*log(rss/n)) + 2*p;
	return(aic);
}

APC<-function(linear_model){
	model_summary<-get_model_summary(linear_model);
	rss<-model_summary[[2]];
	n<-model_summary[[5]];
	p<-model_summary[[3]];
	apc<-((n+p)/(n*(n-p)))*rss;
	return(apc)	
}

BIC<-function(linear_model){
	model_summary<-get_model_summary(linear_model);
	rss<-model_summary[[2]];
	n<-model_summary[[5]];
	p<-model_summary[[3]];
	bic<-n*log(rss)-n*log(n)+p*log(n);
	return(bic);
}

Mallow_Cp<-function(linear_model){
	model_summary<-get_model_summary(linear_model);
	rss<-model_summary[[2]];
	n<-model_summary[[5]];
	p<-model_summary[[3]];
	k<-model_summary[[4]];
	s_squared<-model_summary[[6]];
	cp<-(rss/s_squared)+ 2*k - (n - p - 1);
	return(cp);
}

get_full_model_data<-function(linear_model){
	model_summary <- summary(linear_model);
	analysis_of_variance <- anova(linear_model);
	model_name<-get_model_name(linear_model);
	rss<-analysis_of_variance['Sum Sq'][[1]][[length(analysis_of_variance[[1]])]];
	k<-length(analysis_of_variance[[1]]);
	p<-as.integer(k)-1;
	s_squared<-model_summary['sigma'][[1]]**2;
	r_squared<-model_summary['r.squared'][[1]];
	adjusted_r_squared<-model_summary['adj.r.squared'][[1]];
	aic<-AIC(linear_model);
	bic<-BIC(linear_model);
	apc<-APC(linear_model);
	cp<-Mallow_Cp(linear_model);
	
	return(c(list(
			model_name,
			as.double(rss),
			as.double(p),
			as.double(k),
			as.double(n),
			as.double(s_squared),
			as.double(r_squared),
			as.double(adjusted_r_squared),
			as.double(aic),
			as.double(apc),
			as.double(bic),
			as.double(cp))));
}


#set the main data frame to be used in iterations
main_data_frame <-data.frame(percentageFat);

#Blank column vectors to be appended to
model_name<- c();
rss<-c();
k<-c();
p<-c();
s_squared<-c();
r_squared<-c();
adjusted_r_squared<-c();
aic<-c();
bic<-c();
apc<-c();
cp<-c();


#Generate a matrix with the data
for(model in 1:63){
	data_frame <- main_data_frame;
	combination<-as.binary(model,n=6);
  
	for (n in 1:6){
		if (as.integer(combination[[n]]) == 1){
			data_frame[list_of_predictors[[n]][[2]]] <- list_of_predictors[[n]][[1]] ;          
		}
	}	
	
	#Generate the relevant model data and store
	linear_model<-lm(percentageFat ~ ., data = data_frame);

	full_model_data<-get_full_model_data(linear_model);

	model_name<-append(model_name,full_model_data[[1]]);
	rss<-append(rss,full_model_data[[2]]);
	k<-append(k,full_model_data[[4]]);
	p<-append(p,full_model_data[[3]]);
	s_squared<-append(s_squared,full_model_data[[6]]);
	r_squared<-append(r_squared,full_model_data[[7]]);
	adjusted_r_squared<-append(adjusted_r_squared,full_model_data[[8]]);
	aic<-append(aic,full_model_data[[9]]);
	apc<-append(apc,full_model_data[[10]]);
	bic<-append(bic,full_model_data[[11]]);
	cp<-append(cp,full_model_data[[12]]);
}

#create final data frame 
final_data_frame<-data.frame(models = model_name,
					RSS = rss,k = k,p=p,S_Squared = s_squared,
					R_Squared = r_squared,Adjusted_R_Squared=adjusted_r_squared,
					AIC = aic,APC = apc,BIC = bic,Mallows_Cp = cp);

# An then last but not least, write the data frame export to an excel workbook
#write.xlsx(final_data_frame,file = 'subset models.xlsx');

#DONE---now the diagnostics and analyisis of the data just generated :-)