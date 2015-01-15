#include "utils.h"

#ifdef __WIN32__
#include "windows.h"
#else
#include <sys/stat.h>
#include <utime.h>
#endif

#include <boost/date_time/posix_time/posix_time.hpp>

using namespace std;
using namespace boost::posix_time;

#ifdef __WIN32__

wstring Utils::s2ws(const string &s)
{
	int len;
	int slength = (int)s.length() + 1;
	len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
	wchar_t* buf = new wchar_t[len];
	MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
	wstring r(buf);
	delete[] buf;
	return r;
}

string Utils::ws2s(const wstring &s)
{
	char defaultChar = ' ';

	int len;
	int slength = (int)s.length() + 1;
	len = WideCharToMultiByte(CP_ACP, 0, s.c_str(), slength, 0, 0, &defaultChar, NULL);
	char* buf = new char[len];
	WideCharToMultiByte(CP_ACP, 0, s.c_str(), slength, buf, len, &defaultChar, NULL);
	string r(buf);
	delete[] buf;
	return r;
}

#endif

void Utils::setEnv(const string &env, const string &value)
{
#ifdef __WIN32__

	wstring wenv = Utils::s2ws(env);
	wstring wvalue = Utils::s2ws(value);

	SetEnvironmentVariableW(wenv.c_str(), wvalue.c_str());

#else
	::setenv(env.c_str(), value.c_str(), value.size());
#endif
}

long Utils::currentMillis()
{
	ptime start_of_time = from_iso_string("20150101T000000");
	ptime t = microsec_clock::local_time();
	time_duration elapsed = t - start_of_time;

	return elapsed.total_milliseconds();
}

long Utils::currentSeconds()
{
	time_t now;
	time(&now);

	return now;
}

long Utils::getFileModificationTime(const std::string &filename)
{
#ifdef __WIN32__
	TODO
#elif __APPLE__

	struct stat attrib;
	stat(filename.c_str(), &attrib);
	time_t modificationTime = attrib.st_mtimespec.tv_sec;

	return modificationTime;

#else
	TODO
#endif
}

void Utils::touch(const string &filename)
{
#ifdef __win32__
	TODO
#else
	struct utimbuf newTime;

	time_t newTimeT;
	time(&newTimeT);

	newTime.actime = newTimeT;
	newTime.modtime = newTimeT;

	utime(filename.c_str(), &newTime);
#endif
}

