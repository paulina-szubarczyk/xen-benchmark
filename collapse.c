#include <iostream>
#include <cmath>
#include <string>
#include <fstream>
#include <algorithm>
#include <vector>
#include <iterator>

void file_to_vector(std::vector<float> &sample, std::string file_name) {
	
	if (file_name == "") return;

	std::ifstream file(file_name.c_str());
	
	if (!file.is_open()) return;

	std::string s_num;

	while(!file.eof()){
		std::getline(file, s_num);
		if(atof(s_num.c_str())) 
			sample.push_back(atof(s_num.c_str()));
	}
	file.close();
}

void results_to_file(std::vector<float> &results, char* name) {
	std::ofstream file(name);
	std::ostream_iterator<float> it(file, "\n");
	std::copy(results.begin(), results.end(), it);
	file.close();
}

int main(int argc, char** argv) {

	if (argc < 4) {
		std::cerr << "List of files missing\n";
		return -1;
	}
	
	std::string list_name = std::string(argv[1]);
	std::cout << "Processing " << list_name << std::endl;

	/* import data */
	std::vector<std::vector<float> > data;
	std::ifstream file_list(list_name.c_str());
	std::string file_name;
	while (!file_list.eof()){
		std::getline(file_list, file_name);
		std::cout << "Reading " << file_name << std::endl;
		std::vector<float> sample;
 		file_to_vector(sample, file_name);
		data.push_back(sample);
	}
	file_list.close();

	/* validate size */
	int samples_size = data[0].size();

	if (!samples_size) {
		std::cerr << "Empty data\n";
		return -1;
	}

	for (int i=1; i < data.size(); i++) {
		if (data[i].size() != samples_size) {
			std::cerr << "Inappropriate sample size" 
				  << " i " << i
				  << " of size " << data[i].size() 
				  << " sample size " << samples_size 
				  << std::endl;
			data.erase(data.begin()+i);
		}
	}

	std::cout << "Size of the samples " << samples_size << std::endl;

	/* process */
	std::vector<float> results(samples_size, 0);
	bool latency = std::string(argv[3]).find("latency") != std::string::npos;
	for (int i=0; i < samples_size; i++) {
		for (int j=0; j < data.size(); j++) 
			results[i] += data[j][i];
		results[i] /= (float)data.size();
		if (latency && (results[i] < 100 || 
		   (i > 0 && abs(results[i] - results[i-1]) > 10000 ))) 
			results[i] *= 1000.0;
	}
	
	/* save results to a file */
	std::cout << "Save\n";
	results_to_file(results, argv[2]);
		
	return 0;
}
