# BypassIT

## --- Introduction ---

We now introduce BypassIT as a project to work toward a framework for covert delivery of malware using AutoIT and other Live off the Land (LotL) tools to deliver payloads and to avoid detection. These techniques were derived from reversing attacks observed in the wild by DarkGate and other MaaS actors, revealing universal principles and methods useful for red teaming or internal testing. The framework will consist of a series of tools, techniques, and methods along with testing and reporting on effectiveness.

There are other excellent projects that have talked specifically about the use of AutoIT such as the outstanding resources created by V1V1 (Offensive AutoIT) that we will link to in the resources section. However, some of these projects have not been updated recently in response to recent adversary activity, so it is our intention to build upon and reference these awesome prior projects, while continuing to develop both new offensive scripts that will be tested and maintained as well as new detection logic and tools to better protect against AutoIT-based attacks.  

## --- Scope and Purpose ---

This framework is intended to help fully understand the LotL capabilities that are being used by adversaries, so that we can test them against our own defensive posture and learn where we are week. It can be used by internal testers doing purple teaming as a part of their ongoing operations, or these tools may be useful to red teams who perform security assessments for customers. In either case, we hope the information will be used to discover coverage gaps in products and processes that can be used to inform and educate both security product vendors and individual companies with configuration or procedural gaps.

## --- Ethical Standards / Code of Conduct ---

This project has been started to help better test our products, configurations, detection engineering, and overall security posture against a series of techniques that are being actively used in the wild by adversaries. We can only be successful at properly defending against evasive tactics, if we have the tools and resources to replicate the approaches being used by adversaries in an effective manner. Participation in this project and/or use of these tools implies good intent to use these tools ethically to help better protect/defend, as well as an intent to follow all applicable laws and standards associated with the industry.

## --- Instructions and Overview ---

Please see our [BypassIT Wiki](https://github.com/CroodSolutions/BypassIT/wiki) for details on how to leverage this framework.


## --- How to Contribute ---

We welcome and encourage contributions, participation, and feedback - as long as all participation is legal and ethical in nature. Please develop new scripts, contribute ideas, improve the scripts that we have created. The goal of this project is to come up with a robust testing framework that is available to red/blue/purple teams for assessment purposes, with the hope that one day we can archive this project because improvements to detection logic make this attack vector irrelevant.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## --- Acknowledgments ---

This project would not have been possible without the outstanding contributions of these key researchers:

- [AnuraTheAmphibian](https://github.com/AnuraTheAmphibian)
- [christian-taillon](https://github.com/christian-taillon)
- [Duncan4264](https://github.com/Duncan4264)
- [flawdC0de](https://github.com/flawdC0de)
- [Kitsune-Sec](https://github.com/Kitsune-Sec)
- [shammahwoods](https://github.com/shammahwoods)
- [matt-handy](https://github.com/matt-handy) 

Also, this builds upon prior research done by many outstanding security professionals who have paved the way:

- [0xToxin](https://0xtoxin.github.io/threat%20breakdown/DarkGate-Camapign-Analysis/)
- [V1V1](https://github.com/V1V1/OffensiveAutoIt?tab=readme-ov-file#setting-up-a-dev-environment)

(this project is in beta, so we are still organizing our notes on acknowledgements - more to follow)
